class Donation < ApplicationRecord
  belongs_to :event
  belongs_to :fee_reimbursement, required: false
  belongs_to :payout, class_name: 'DonationPayout', required: false

  before_create :create_stripe_payment_intent
  before_create :assign_unique_hash

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

  private

  def create_stripe_payment_intent
    payment_intent = StripeService::PaymentIntent.create({
                                                           amount: self.amount,
                                                           currency: 'usd'
                                                         })

    self.stripe_payment_intent_id = payment_intent.id

    self.set_fields_from_stripe_payment_intent(payment_intent)
  end

  def assign_unique_hash
    self.url_hash = SecureRandom.hex(8)
  end
end
