# frozen_string_literal: true

# == Schema Information
#
# Table name: wires
#
#  id                        :bigint           not null, primary key
#  aasm_state                :string           not null
#  account_number_bidx       :string           not null
#  account_number_ciphertext :string           not null
#  amount_cents              :integer          not null
#  approved_at               :datetime
#  bic_code_bidx             :string           not null
#  bic_code_ciphertext       :string           not null
#  currency                  :string           default("USD"), not null
#  memo                      :string           not null
#  payment_for               :string           not null
#  recipient_email           :string           not null
#  recipient_name            :string           not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  event_id                  :bigint           not null
#  user_id                   :bigint           not null
#
# Indexes
#
#  index_wires_on_event_id  (event_id)
#  index_wires_on_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => events.id)
#  fk_rails_...  (user_id => users.id)
#
class Wire < ApplicationRecord
  has_paper_trail

  include PgSearch::Model
  pg_search_scope :search_recipient, against: [:recipient_name, :recipient_email]

  has_encrypted :account_number, :bic_code
  blind_index :account_number, :bic_code

  include AASM

  include CountryEnumable
  enum :recipient_country, self.country_enum_list, prefix: :recipient_country

  belongs_to :event
  belongs_to :user

  has_one :canonical_pending_transaction

  monetize :amount_cents, as: "amount", with_model_currency: :currency

  include PublicActivity::Model
  tracked owner: proc{ |controller, record| controller&.current_user }, event_id: proc { |controller, record| record.event.id }, only: [:create]

  ESTIMATED_FEE_CENTS_USD = 25_00

  after_create do
    create_canonical_pending_transaction!(
      event:,
      amount_cents: -1 * (usd_amount_cents + ESTIMATED_FEE_CENTS_USD),
      memo: "OUTGOING WIRE",
      date: created_at
    )
  end

  aasm timestamps: true, whiny_persistence: true do
    state :pending, initial: true
    state :approved
    state :rejected
    state :deposited

    event :mark_approved do
      transitions from: :pending, to: :approved
    end

    event :mark_rejected do
      after do
        canonical_pending_transaction.decline!
        create_activity(key: "wire.rejected")
      end
      transitions from: [:pending, :approved], to: :rejected
    end

    event :mark_deposited do
      transitions from: :approved, to: :deposited
      after do
        DisbursementService::Create.new(
          source_event_id: event_id,
          destination_event_id: EventMappingEngine::EventIds::HACK_CLUB_BANK,
          name: "Fee for international wire (#{id})",
          amount: Wire::ESTIMATED_FEE_CENTS_USD / 100
        ).run
      end
    end
  end

  validates :amount_cents, numericality: { greater_than: 0, message: "must be positive!" }

  validates :recipient_email, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }

  validates_presence_of :memo, :payment_for, :recipient_name, :recipient_email

  validate on: :create do
    if (usd_amount_cents + estimated_fee_cents_usd) > event.balance_available_v2_cents
      errors.add(:base, "You don't have enough money to send this transfer! Your balance is #{(event.balance_available_v2_cents / 100).to_money.format}. At current exchange rates, this transfer would cost #{((usd_amount_cents + estimated_fee_cents_usd) / 100).to_money.format} (USD, including fees).")
    end
  end

  def state
    if pending?
      :muted
    elsif rejected?
      :error
    elsif deposited?
      :success
    else
      :info
    end
  end

  def state_text
    aasm_state.humanize
  end

  alias_attribute :name, :recipient_name

  def hcb_code
    "HCB-#{TransactionGroupingEngine::Calculate::HcbCode::WIRE_CODE}-#{id}"
  end

  def admin_dropdown_description
    "#{ApplicationController.helpers.render_money(amount_cents)} to #{recipient_email} from #{event.name}"
  end

  def local_hcb_code
    @local_hcb_code ||= HcbCode.find_or_create_by(hcb_code:)
  end

  def usd_amount_cents
    eu_bank = EuCentralBank.new
    eu_bank.update_rates
    eu_bank.exchange(amount_cents, currency, "USD").cents
  end

  def self.information_required_for(country) # country can be null, in which case, only the general fields will be returned.
    fields = []
    case country
    when "BR"
      fields << { type: :text_field, key: "phone", label: "Phone number associated with account" }
      fields << { type: :text_field, key: "email", label: "Email address associated with account" }
      fields << { type: :text_field, key: "legal_type", label: "Legal status of receiving entity" }
      fields << { type: :text_field, key: "legal_id", label: "Legal ID of receiving entity", description: "11-digit CPF for individuals, or 14-digit CNPJ for corporations/NGO/organizations" }
      fields << { type: :text_area, key: "remittance_info", label: "Remittance information", description: "Payment purpose must be clearly identified" }
    when "BH"
      fields << { type: :text_area, key: "purpose_code", label: "Purpose code", description: "A 3-character purpose of payment code.", refer_to: "https://cbben.thomsonreuters.com/rulebook/mandating-use-purpose-codes-swift-cross-border-payments4-january-2021" }
    when "CL"
      fields << { type: :text_field, key: "legal_id", label: "Legal ID of receiving entity", description: "9-digit RUT tax ID" }
      fields << { type: :text_area, key: "purpose_code", label: "Purpose code", description: "A 5-digit purpose of payment code.", refer_to: "https://www.bcentral.cl/documents/33528/133521/Manual+de+Procedimientos+y+Formularios+de+Informaci%C3%B3n+del+CN%20CI.pdf/bcdfb774-330a-c6e1-b9fd-1b5e2c078426?t=1583165824643" }
    when "CO"
      fields << { type: :text_field, key: "phone", label: "Phone number associated with account" }
      fields << { type: :text_field, key: "email", label: "Email address associated with account" }
      fields << { type: :text_field, key: "legal_type", label: "Legal status of receiving entity" }
      fields << { type: :text_field, key: "legal_id", label: "Legal ID of receiving entity", description: "7-11 digits Cédulas for individuals, or 10-digit NIT for corporations/NGO/organizations" }
      fields << { type: :text_area, key: "purpose_code", label: "Payment purpose", description: "A clearly identifiable purpose of payment (e.g., goods, services, capital, etc.)" }
    when "DO"
      fields << { type: :text_field, key: "account_type", label: "Account type" }
      fields << { type: :text_field, key: "legal_type", label: "Legal status of receiving entity" }
      fields << { type: :text_field, key: "legal_id", label: "Legal ID of receiving entity", description: "11-digit Cedula or passport number for individuals, or 7+ digits tax ID or 9+ digits Registro Mercantil for corporations/NGO/organizations" }
    when "HN"
      fields << { type: :text_field, key: "account_type", label: "Account type" }
      fields << { type: :text_field, key: "legal_type", label: "Legal status of receiving entity" }
      fields << { type: :text_field, key: "legal_id", label: "Legal ID of receiving entity", description: "13-digit Tarjeta de Identidad for individuals, or 14-digit Registro Tributario Nacional for corporations/NGO/organizations" }
      fields << { type: :text_area, key: "remittance_info", label: "Remittance information", description: "For payments from corporations/organizations to individuals, include a detailed purpose of payment (especially for salaries)" }
    when "KZ"
      fields << { type: :text_field, key: "legal_type", label: "Legal status of receiving entity" }
      fields << { type: :text_field, key: "legal_id", label: "Legal ID of receiving entity", description: "12-digit Business Identification Number (BIN) or Individual Identification Number (IIN)" }
      fields << { type: :text_area, key: "remittance_info", label: "Remittance information", description: "Payment purpose must be clearly identified" }
      fields << { type: :text_area, key: "purpose_code", label: "Payment purpose", description: "A 10-character EKNP purpose code" }
    when "MD"
      fields << { type: :text_field, key: "phone", label: "Phone number associated with account" }
    when "MY"
      fields << { type: :text_field, key: "legal_type", label: "Legal status of receiving entity" }
      fields << { type: :text_area, key: "purpose_code", label: "Purpose code", description: "A 5-digit purpose of payment code.", refer_to: "https://connect-content.us.hsbc.com/hsbc_pcm/onetime/17_july_my_pop_codes.pdf" }
    when "PK"
      fields << { type: :text_field, key: "legal_type", label: "Legal status of receiving entity" }
      fields << { type: :text_field, key: "legal_id", label: "Legal ID of receiving entity", description: "Should be prepended with CNIC, SNIC, Passport, or NTN depending on the ID type." }
      fields << { type: :text_area, key: "purpose_code", label: "Purpose code", description: "A 4-digit purpose of payment code.", refer_to: "https://www.sbp.org.pk/fe_returns/cod5.pdf" }
    when "PY"
      fields << { type: :text_field, key: "legal_type", label: "Legal status of receiving entity" }
      fields << { type: :text_field, key: "legal_id", label: "Legal ID of receiving entity", description: "Cedula de Identidad for individuals, or RUC for corporations" }
    when "AM"
      fields << { type: :text_field, key: "legal_type", label: "Legal status of receiving entity" }
      fields << { type: :text_area, key: "remittance_info", label: "Remittance information", description: "Payment purpose must be clearly identified" }
    when "AR"
      fields << { type: :text_field, key: "email", label: "Email address associated with account" }
      fields << { type: :text_field, key: "legal_id", label: "Legal ID of receiving entity", description: "11-digit CUIL for individuals, or 11-digit CUIT for corporations" }
    when "AE"
      fields << { type: :text_area, key: "remittance_info", label: "Remittance information", description: "Payment purpose must be clearly identified" }
      fields << { type: :text_area, key: "purpose_code", label: "Purpose code", description: "A 3-character purpose of payment code.", refer_to: "https://www.centralbank.ae/media/ipaifsll/bop-purposeofpaymentcodestable-en-18092017.pdf" }
    when "AL"
      fields << { type: :text_area, key: "remittance_info", label: "Remittance information", description: "For utility payments: client name, bill month, and contract number of the subscriber. For tax payments: FDP (payment order document generated by Tax Office system). For fee payments: NIPT (tax ID)." }
    when "AU"
      fields << { type: :text_field, key: "local_bank_code", label: "Local bank code", description: "6-digit BSB code" }
    when "AZ"
      fields << { type: :text_field, key: "legal_id", label: "Legal ID of receiving entity", description: "10-digit TIN/VOEN" }
      fields << { type: :text_field, key: "local_bank_code", label: "Local bank code", description: "6-digit BIK code" }
      fields << { type: :text_area, key: "remittance_info", label: "Remittance information", description: "Payment purpose must be clearly identified, especially for charitable purposes to avoid income tax" }
    when "BA"
      fields << { type: :text_area, key: "remittance_info", label: "Remittance information", description: "If the beneficiary belongs to a government organization, Budget Organization Code, Profit Type (6-digit) and Citation Number (municipality, 3-digit) are required" }
    when "BG"
      fields << { type: :text_area, key: "remittance_info", label: "Remittance information", description: "For tax payments: 6-digit payment type defined by the Ministry of Finance and local regulation, and one of the following: BULSTAT (Bulgarian Identification Tax Number, 6-digit for corporations), EGN (Bulgarian citizen ID), PNF (foreign citizen ID), or IZL (name of legal entity or individual)" }
    when "BD"
      fields << { type: :text_field, key: "phone", label: "Phone number associated with account" }
      fields << { type: :text_field, key: "local_bank_code", label: "Local bank code", description: "9-digit bank routing code" }
    when "BY"
      fields << { type: :text_field, key: "local_bank_code", label: "Local bank code", description: "3-9 digits MFO bank code" }
      fields << { type: :text_field, key: "legal_id", label: "Legal ID of receiving entity", description: "Tax ID" }
      fields << { type: :text_area, key: "remittance_info", label: "Remittance information", description: "Payment purpose must be clearly identified" }
    when "BZ"
      fields << { type: :text_field, key: "local_bank_code", label: "Local bank code", description: "5-digit branch code" }
    when "BS"
      fields << { type: :text_area, key: "remittance_info", label: "Remittance information", description: "Transit Number is required if the beneficiary bank is RBC Bahamas" }
    when "CA"
      fields << { type: :text_field, key: "local_bank_code", label: "Local bank code", description: "9-digit Canadian Payments Association Routing Number" }
    when "CM"
      fields << { type: :text_field, key: "phone", label: "Phone number associated with account" }
    when "CN"
      fields << { type: :text_area, key: "purpose_code", label: "Purpose code", description: "CAP (Capital Account), GDS (Goods Trade), SRV (Service Trade), CAC (Current Account), or FTF (Bank to Bank Funds Transfer)" }
    when "CR"
      fields << { type: :text_field, key: "legal_id", label: "Legal ID of receiving entity", description: "9-12 digits Cedula Juridica" }
      fields << { type: :text_field, key: "local_account_number", label: "Local account number", description: "17-digit Cuenta Cliente" }
    when "DZ"
      fields << { type: :text_area, key: "remittance_info", label: "Remittance information", description: "For invoices: reason for the invoice (e.g., invoice for health services). Otherwise provide a general reason for payment." }
    when "GY"
      fields << { type: :text_area, key: "remittance_info", label: "Remittance information", description: "8-digit Transit Code is mandatory (format: TRANSIT CODE: XXXXXXXX). Funds paid to the Guyana Revenue Authority requires a reference (format: YYMMDD/RRRRRRRRRRRR), which can be obtained from the Guyana Revenue Authority." }
    when "ID"
      fields << { type: :text_field, key: "phone", label: "Phone number associated with account" }
    when "IN"
      fields << { type: :text_field, key: "legal_type", label: "Legal status of receiving entity" }
      fields << { type: :text_field, key: "phone", label: "Phone number associated with account" }
      fields << { type: :text_field, key: "local_bank_code", label: "Local bank code", description: "11-character IFSC codes" }
      fields << { type: :text_area, key: "purpose_code", label: "Purpose code", description: "A 5-character purpose of payment code, beginning with 'P'.", refer_to: "https://rbidocs.rbi.org.in/rdocs/notification/PDFs/ASAP840212FL.pdf" }
    when "JO"
      fields << { type: :text_area, key: "remittance_info", label: "Remittance information", description: "Payment purpose must be clearly identified" }
      fields << { type: :text_area, key: "purpose_code", label: "Purpose code", description: "A 4-digit purpose of payment code.", refer_to: "https://www.cbj.gov.jo/EchoBusv3.0/SystemAssets/PDFs/1%D8%A7%D9%84%D8%BA%D8%B1%D8%B6%20%D9%85%D9%86%20%D8%A7%D9%84%D8%AA%D8%AD%D9%88%D9%8A%D9%84%D8%A7%D8%AA%200%D8%A7%D9%84%D9%85%D8%A7%D9%84%D9%8A%D8%A9-20191029.pdf" }
    when "KG"
      fields << { type: :text_field, key: "local_bank_code", label: "Local bank code", description: "6-digit BIK code" }
      fields << { type: :text_area, key: "purpose_code", label: "Purpose code", description: "A 8-digit purpose of payment code" }
    when "KR"
      fields << { type: :text_field, key: "phone", label: "Phone number associated with account" }
      fields << { type: :text_field, key: "legal_type", label: "Legal status of receiving entity" }
      fields << { type: :text_field, key: "legal_id", label: "Legal ID of receiving entity", description: "10-digit Business Registration Number (for corporations)" }
      fields << { type: :text_area, key: "purpose_code", label: "Purpose code", description: "A 5-digit purpose of payment code.", refer_to: "https://www.jpmorgan.com/directdoc/list-of-payment-purpose-code-kr.pdf" }
    when "MU"
      fields << { type: :text_area, key: "remittance_info", label: "Remittance information", description: "Payment purpose must be clearly identified" }
    when "MM"
      fields << { type: :text_area, key: "purpose_code", label: "Purpose code", description: "A 4-digit ITRS code" }
    when "MX"
      fields << { type: :text_field, key: "clabe_code", label: "CLABE code", description: "18-digit standard for bank account numbers in Mexico" }
      fields << { type: :text_field, key: "local_bank_code", label: "Local bank code", description: "Nostro Account Number" }
    when "MZ"
      fields << { type: :text_field, key: "legal_id", label: "Legal ID of receiving entity", description: "9-digit NUIT: Taxpayer Single ID Number" }
    when "NE"
      fields << { type: :text_field, key: "phone", label: "Phone number associated with account" }
    when "NP"
      fields << { type: :text_area, key: "remittance_info", label: "Remittance information", description: "9-digit Permanent Account Number (PAN) is required for (i) payments related to social media content and software development by individuals or corporations or equivalent and (ii) payments related to any consultancy services would apply to individual only." }
    when "NZ"
      fields << { type: :text_field, key: "local_bank_code", label: "Local bank code", description: "6-digit NZ Clearing Code" }
    when "PE"
      fields << { type: :text_field, key: "legal_type", label: "Legal status of receiving entity" }
      fields << { type: :text_field, key: "legal_id", label: "Legal ID of receiving entity", description: "11-digit RUC number for corporations, or 8-digit DNI for individuals" }
    when "TG"
      fields << { type: :text_field, key: "phone", label: "Phone number associated with account" }
    when "TW"
      fields << { type: :text_field, key: "phone", label: "Phone number associated with account" }
    when "UA"
      fields << { type: :text_field, key: "type", label: "Type of entity" }
      fields << { type: :text_field, key: "legal_id", label: "Legal ID of receiving entity", description: "10-digit tax ID for individuals, or 8-digit tax ID for corporations/NGO/organizations" }
    when "UG"
      fields << { type: :text_field, key: "legal_id", label: "Legal ID of receiving entity", description: "13-digit PRN tax ID" }
    when "SA"
      fields << { type: :text_area, key: "remittance_info", label: "Remittance information", description: "Payment purpose must be clearly identified" }
    when "ZM"
      fields << { type: :text_field, key: "local_bank_code", label: "Local bank code", description: "6-digit branch code" }
    when "ZA"
      fields << { type: :text_area, key: "remittance_info", label: "Remittance information", description: "For Tax payments, include unique 19 character Payment Reference Number(PRN) (e.g., /PRN/xxxxxxxxxxxxxxxxxxx)" }
    else
      fields << { type: :text_area, key: "instructions", label: "Country-specific instructions", description: "Use this space to include specific details required to send to this country." }
    end
    return fields
  end

  def self.recipient_information_accessors
    fields = []
    Event.countries_for_select.each do |country|
      fields += self.information_required_for(country[0])
    end
    fields.collect{ |field| field[:key] }.uniq
  end

  store :recipient_information, accessors: self.recipient_information_accessors

end
