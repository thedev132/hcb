# frozen_string_literal: true

class AddReceiptableToReceipts < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  class Receipt < ActiveRecord::Base
    self.ignored_columns = ["stripe_authorization_id"]
  end

  def up
    add_reference :receipts, :receiptable, polymorphic: true, index: {algorithm: :concurrently}

    Receipt.where("stripe_authorization_id IS NOT NULL").update_all(receiptable_type: "StripeAuthorization")
    Receipt.where("stripe_authorization_id IS NOT NULL").update_all("receiptable_id = stripe_authorization_id")

    safety_assured { remove_reference :receipts, :stripe_authorization }
  end

  def down
    add_reference :receipts, :stripe_authorization, index: {algorithm: :concurrently}

    Receipt.where(receiptable_type: "StripeAuthorization").update_all("stripe_authorization_id = receiptable_id")

    remove_reference :receipts, :receiptable, polymorphic: true
  end
end
