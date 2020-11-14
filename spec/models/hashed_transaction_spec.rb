# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HashedTransaction, type: :model do
  fixtures 'raw_emburse_transactions', 'hashed_transactions'

  let(:hashed_transaction) { hashed_transactions(:hashed_transaction1) }

  it 'is valid' do
    expect(hashed_transaction).to be_valid
  end

  describe '#memo' do
    context 'source is emburse without memo details' do
      let(:hashed_transaction) { hashed_transactions(:hashed_transaction2) }

      it 'generates blank memo' do
        expect(hashed_transaction.memo).to eql('')
      end
    end
  end
end
