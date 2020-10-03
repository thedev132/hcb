# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmburseTransaction, type: :model do
  fixtures 'emburse_transactions'

  let(:emburse_transaction) { emburse_transactions(:emburse_transaction1) }

  it 'is valid' do
    expect(emburse_transaction).to be_valid
  end

  describe '#memo' do
    context 'amount is negative and merchant name is null' do
      it 'is a transfer back to bank account' do
        expect(emburse_transaction.memo).to eql('Transfer back to bank account')
      end
    end

    context 'amount is postitive and merchant name is null' do
      before do
        allow(emburse_transaction).to receive(:amount).and_return(100)
      end

      it 'is a transfer from bank account' do
        expect(emburse_transaction.memo).to eql('Transfer from bank account')
      end
    end

    context 'amount is positive and merchant name is somehow present' do
      before do
        allow(emburse_transaction).to receive(:merchant_name).and_return('Some merchant name')
        allow(emburse_transaction).to receive(:amount).and_return(100)
      end

      it 'is still a transfer from bank account' do
        expect(emburse_transaction.memo).to eql('Transfer from bank account')
      end
    end

    context 'amount is negative and merchant name is present' do
      before do
        allow(emburse_transaction).to receive(:merchant_name).and_return('Some merchant name')
      end

      it 'uses merchant name as memo' do
        expect(emburse_transaction.memo).to eql('Some merchant name')
      end
    end
  end

  describe '#transfer?' do
    context 'amount is negative and merchant name is null' do
      it 'is a transfer' do
        expect(emburse_transaction).to be_transfer
      end
    end

    context 'amount is postitive and merchant name is null' do
      before do
        allow(emburse_transaction).to receive(:amount).and_return(100)
      end

      it 'is a transfer from bank account' do
        expect(emburse_transaction).to be_transfer
      end
    end

    context 'amount is positive and merchant name is somehow present' do
      before do
        allow(emburse_transaction).to receive(:merchant_name).and_return('Some merchant name')
        allow(emburse_transaction).to receive(:amount).and_return(100)
      end

      it 'is still a transfer from bank account' do
        expect(emburse_transaction).to be_transfer
      end
    end

    context 'amount is negative and merchant name is present' do
      before do
        allow(emburse_transaction).to receive(:merchant_name).and_return('Some merchant name')
      end

      it 'is not a transfer' do
        expect(emburse_transaction).to_not be_transfer
      end
    end
  end

end
