class BankAccount < ApplicationRecord
  has_many :transactions

  scope :syncing, -> { where(should_sync: true) }
  scope :syncing_v2, -> { where(should_sync_v2: true) }

  def balance
    self.transactions.sum(:amount)
  end

  def pull_transactions_from!(account)
    # Utility that will look at another account and try to make all the same connections

    # 🍤.pull_transactions_from 🐉
    # 🍤 will pull transactions over & update their plaid info
    ActiveRecord::Base.transaction do
      self.transactions.with_deleted.each do |original_t|
        overwriting_t = account.transactions.find_by(
          name: original_t.name,
          amount: original_t.amount,
          location_address: original_t.location_address,
          date: original_t.date,
          pending: original_t.pending,
        )

        unless overwriting_t
          puts "No synonym transaction found for ##{original_t.id} (#{original_t.name})"
          next
        end

        puts "Found synonyms: ##{original_t.id} written over by #{overwriting_t.id} (#{original_t.name})"
        plaid_id = original_t.plaid_id
        original_t.update_attributes!(
          plaid_id: original_t.plaid_id + '-bak',
          name: "BACKUP TX: " + original_t.name
        )
        overwriting_t.update_attributes!(
          bank_account: self,
          plaid_id: plaid_id,
          plaid_category_id: original_t.plaid_category_id,
          pending_transaction_id: original_t.pending_transaction_id,
        )
        original_t.destroy
      end
    end
  end
end
