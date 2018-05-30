class Sponsor < ApplicationRecord
  belongs_to :event
  has_many :invoices

  validates_presence_of :name, :contact_email

  before_create :create_stripe_customer
  before_update :update_stripe_customer
  before_destroy :destroy_stripe_customer

  def create_stripe_customer
    cu = StripeService::Customer.create(stripe_params)
    self.stripe_customer_id = cu.id
  end

  def update_stripe_customer
    cu = Stripe::Customer.retrieve(self.stripe_customer_id)

    stripe_params.each do |k, v|
      cu.send("#{k}=", v)
    end

    cu.save
  end

  def destroy_stripe_customer
    cu = StripeService::Customer.retrieve(self.stripe_customer_id)
    cu.delete
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
end
