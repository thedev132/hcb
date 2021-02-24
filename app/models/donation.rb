class Donation < ApplicationRecord
  include Commentable
  belongs_to :event
  belongs_to :fee_reimbursement, required: false
  belongs_to :payout, class_name: 'DonationPayout', required: false

  before_create :create_stripe_payment_intent
  before_create :assign_unique_hash

  after_update :send_payment_notification_if_needed

  validates :name, :email, :amount, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 100 }
  validate :email_must_not_be_riddick

  scope :succeeded, -> { where(status: "succeeded") }
  scope :not_succeeded, -> { where("status != 'succeeded'") }
  scope :not_riddick, -> { where("email ilike 'riddick39462@gmail.com'") }

  def set_fields_from_stripe_payment_intent(payment_intent)
    self.amount = payment_intent.amount
    self.amount_received = payment_intent.amount_received
    self.status = payment_intent.status
    self.stripe_client_secret = payment_intent.client_secret
  end

  def stripe_dashboard_url
    "https://dashboard.stripe.com/payments/#{self.stripe_payment_intent_id}"
  end

  def status_color
    return 'success' if deposited?
    return 'info' if pending?

    'error'
  end

  def status_text
    return 'Deposited' if deposited?
    return 'Pending' if pending?

    'Contact Hack Club Bank staff'
  end

  def deposited?
    status == 'succeeded' && self&.payout&.t_transaction.present?
  end

  def pending?
    status == 'succeeded' && !deposited?
  end

  def unpaid?
    status == 'requires_payment_method'
  end

  def filter_data
    {
      in_transit: (status == 'succeeded' && payout_id == nil),
      deposited: (status == 'succeeded' && self&.payout&.t_transaction.present?),
      exists: true
    }
  end

  def create_payout!
    pi = StripeService::PaymentIntent.retrieve(id: stripe_payment_intent_id, expand: ['charges.data.balance_transaction'])

    raise StandardError, 'Funds not yet available' unless Time.current.to_i > pi.charges.data.first.balance_transaction.available_on

    self.payout = DonationPayout.new(
      donation: self
    )

    self.fee_reimbursement = FeeReimbursement.new(
      donation: self
    )

    self.fee_reimbursement.save

    # if a transfer takes longer than 5 days something is probably wrong. so send an email
    fee_reimbursement_job = SendUnmatchedFeeReimbursementEmailJob.set(wait_until: DateTime.now + 5.days).perform_later(self.fee_reimbursement)
    self.fee_reimbursement.mailer_queued_job_id = fee_reimbursement_job.provider_job_id

    # saving a second time because we needed the fee reimbursement to exist in order to capture the job id
    self.fee_reimbursement.save

    save!
  end

  def send_receipt!
    DonationMailer.with(donation: self).donor_receipt.deliver_later
  end

  def arrival_date
    self&.payout&.arrival_date || 3.business_days.after(payout_creation_queued_for)
  end

  def arriving_late?
    DateTime.now > self.arrival_date
  end

  def payment_method_type
    stripe_obj.dig(:payment_method, :type)
  end

  def payment_method_card_brand
    stripe_obj.dig(:payment_method, :card, :brand)
  end

  def payment_method_card_last4
    stripe_obj.dig(:payment_method, :card, :last4)
  end

  def payment_method_card_funding
    stripe_obj.dig(:payment_method, :card, :funding)
  end

  def payment_method_card_exp_month
    stripe_obj.dig(:payment_method, :card, :exp_month)
  end

  def payment_method_card_exp_year
    stripe_obj.dig(:payment_method, :card, :exp_year)
  end

  def payment_method_card_country
    stripe_obj.dig(:payment_method, :card, :country)
  end

  def payment_method_card_checks_address_line1_check
    stripe_obj.dig(:payment_method, :card, :checks, :address_line1_check)
  end

  def payment_method_card_checks_address_postal_code_check
    stripe_obj.dig(:payment_method, :card, :checks, :address_postal_code_check)
  end

  def payment_method_card_checks_cvc_check
    stripe_obj.dig(:payment_method, :card, :checks, :cvc_check)
  end

  def stripe_obj
    @stripe_donation_obj ||=
      StripeService::PaymentIntent.retrieve(id: stripe_payment_intent_id, expand: ['payment_method']).to_hash
  end

  private

  def send_payment_notification_if_needed
    return unless saved_changes[:status].present?

    was = saved_changes[:status][0] # old value of status
    now = saved_changes[:status][1] # new value of status

    if was != 'succeeded' && now == 'succeeded'
      # send special email on first donation paid
      if self.event.donations.select { |d| d.status == 'succeeded' }.count == 1
        DonationMailer.with(donation: self).first_donation_notification.deliver_later
        return
      end
    end
  end

  def create_stripe_payment_intent
    payment_intent = StripeService::PaymentIntent.create({
                                                           amount: self.amount,
                                                           currency: 'usd',
                                                           metadata: { 'donation': true }
                                                         })

    self.stripe_payment_intent_id = payment_intent.id

    self.set_fields_from_stripe_payment_intent(payment_intent)
  end

  def assign_unique_hash
    self.url_hash = SecureRandom.hex(8)
  end

  def email_must_not_be_riddick
    self.errors.add(:email, "has been reported") if email.to_s.strip.downcase == "riddick39462@gmail.com"
  end
end
