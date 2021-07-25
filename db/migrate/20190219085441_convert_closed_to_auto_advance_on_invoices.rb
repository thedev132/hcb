# frozen_string_literal: true

class ConvertClosedToAutoAdvanceOnInvoices < ActiveRecord::Migration[5.2]
  class Invoice < ActiveRecord::Base; end

  def up
    rename_column :invoices, :closed, :auto_advance

    # flip values as auto_advance is the opposite of closed, see stripe
    # migration docs (https://i.imgur.com/ncfEfZ9.png screenshot) for details
    Invoice.update_all("auto_advance = NOT auto_advance")
  end

  def down
    rename_column :invoices, :auto_advance, :closed
    Invoice.update_all("closed = NOT closed")
  end
end
