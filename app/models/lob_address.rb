# frozen_string_literal: true

class LobAddress < ApplicationRecord
  has_many :checks
  belongs_to :event, required: true

  before_create :default_values
  before_create :create_lob_address
  before_update :update_lob_address
  before_destroy :destroy_lob_address

  def set_fields_from_lob_address(lob_address)
    self.description = lob_address["description"]
    self.name = lob_address["name"]
    self.address1 = lob_address["address_line1"]
    self.address2 = lob_address["address_line2"]
    self.city = lob_address["address_city"]
    self.state = lob_address["address_state"]
    self.zip = lob_address["address_zip"]
    self.country = lob_address["address_country"]
    self.lob_id = lob_address["id"]
  end

  def address_text
    "#{address1} #{address2} - #{city}, #{state} #{zip}"
  end

  private

  def default_values
    self.country = "US"
    self.description = "#{name} - #{address1}"
  end

  def create_lob_address
    lob_address = LobService.instance.add_address(
      description,
      name,
      address1,
      address2,
      city,
      state,
      zip,
      country
    )

    set_fields_from_lob_address(lob_address)
  end

  def update_lob_address
    lob_address = LobService.instance.update_address(
      lob_id,
      description,
      name,
      address1,
      address2,
      city,
      state,
      zip,
      country
    )

    set_fields_from_lob_address(lob_address)
  end

  def destroy_lob_address
    LobService.instance.delete_address(lob_id)
  end
end
