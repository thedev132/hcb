class Sponsor < ApplicationRecord
  extend FriendlyId

  include PgSearch::Model
  pg_search_scope :search_name, against: [:name, :contact_email]

  friendly_id :slug_candidates, use: :slugged

  belongs_to :event
  has_many :invoices

  validates_presence_of :name, :contact_email, :address_line1, :address_city,
                        :address_state, :address_postal_code

  before_create :create_stripe_customer
  before_update :update_stripe_customer
  before_destroy :destroy_invoices
  before_destroy :destroy_stripe_customer

  def status
    i = invoices.last
    if i.nil?
      :muted
    elsif i.paid?
      :success
    elsif i.due_date < Time.current
      :error
    elsif i.due_date < 3.days.from_now
      :warning
    else
      :muted
    end
  end

  def status_description
    i = invoices.last
    if i.nil?
      'No invoices yet'
    elsif i.paid?
      'Last invoice paid'
    elsif i.due_date < Time.current
      'Last invoice overdue + unpaid'
    elsif i.due_date < 5.days.from_now
      'Last invoice due soon'
    else
      'Last invoice due further out'
    end
  end

  def create_stripe_customer
    cu = StripeService::Customer.create(stripe_params)
    self.stripe_customer_id = cu.id
  end

  def update_stripe_customer
    cu = StripeService::Customer.retrieve(self.stripe_customer_id)

    stripe_params.each do |k, v|
      cu.send("#{k}=", v)
    end

    cu.save
  end

  def destroy_stripe_customer
    cu = StripeService::Customer.retrieve(self.stripe_customer_id)
    cu.delete
  end

  def destroy_invoices
    self.invoices.destroy_all
  end

  def stripe_dashboard_url
    url = 'https://dashboard.stripe.com'

    if StripeService.mode == :test
      url += '/test'
    end

    url += "/customers/#{self.stripe_customer_id}"

    url
  end

  private

  def stripe_params
    {
      description: self.name,
      email: self.contact_email,
      shipping: {
        name: self.name,
        address: {
          line1: self.address_line1,
          line2: self.address_line2,
          city: self.address_city,
          state: self.address_state,
          postal_code: self.address_postal_code
        }
      }
    }
  end

  def slug_candidates
    [
      :name,
      [:name, -> { self.event.name }]
    ]
  end
end
