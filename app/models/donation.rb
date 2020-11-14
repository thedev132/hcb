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

  def set_fields_from_stripe_payment_intent(payment_intent)
    self.amount = payment_intent.amount
    self.amount_received = payment_intent.amount_received
    self.status = payment_intent.status
    self.stripe_client_secret = payment_intent.client_secret
  end

  def queue_payout!
    pi = StripeService::PaymentIntent.retrieve(id: stripe_payment_intent_id, expand: ['charges.data.balance_transaction'])
    raise NoAssociatedStripeCharge if pi.charges.nil?

    # get the balance transaction of the first (and only) charge
    b_tnx = pi.charges.data.first.balance_transaction

    funds_available_at = Util.unixtime(b_tnx.available_on)
    create_payout_at = funds_available_at + 1.day

    job = CreatePayoutJob.set(wait_until: create_payout_at).perform_later(self)

    self.payout_creation_queued_at = DateTime.current
    self.payout_creation_queued_for = create_payout_at
    self.payout_creation_queued_job_id = job.job_id
    self.payout_creation_balance_net = b_tnx.net # amount to pay out
    self.payout_creation_balance_stripe_fee = b_tnx.fee
    self.payout_creation_balance_available_at = funds_available_at

    self.save!
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

    'Contact your point of contact'
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
end
