# frozen_string_literal: true

require 'rails_helper'

describe LoginCode do
  context 'when LoginCode is initialized' do
    it 'is valid and generates a code' do
      login_code = build(:login_code)
      expect(login_code.code.length).to eq(6)
      expect(login_code).to be_valid
    end
  end

  describe '#pretty' do
    it 'formats with a - in the middle' do
      login_code = build(:login_code)
      expect(login_code.pretty.length).to eq(7)
      expect(login_code.pretty[3]).to eq('-')
    end
  end

  describe '#active?' do
    it 'is true when used_at is nil' do
      login_code = build(:login_code, used_at: nil)
      expect(login_code).to be_active
    end

    it 'is true when used_at is present' do
      login_code = build(:login_code, used_at: DateTime.current)
      expect(login_code).to_not be_active
    end
  end

  describe '#generate_code' do
    let(:existing_login_code) { create(:login_code) }

    before do
      existing_login_code.update(code: 123456)
    end

    context 'when existing login_code is active' do
      before do
        expect(existing_login_code).to be_active
        expect(SecureRandom).to receive(:random_number).with(999_999).and_return(123456, 987654)
      end

      it 'gets called twice' do
        second_login_code = build(:login_code)
        expect(second_login_code.code).to eq('987654')
      end
    end

    context 'when existing login_code is used' do
      before do
        existing_login_code.update(used_at: Date.current)
        expect(existing_login_code).to_not be_active
        expect(SecureRandom).to receive(:random_number).with(999_999).and_return(123456)
      end

      it 'gets called once and can reuse the code' do
        second_login_code = build(:login_code)
        expect(second_login_code.code).to eq('123456')
      end
    end
  end

  context 'duplicate login_codes' do
    context 'when an existing code is active' do
      it 'fails saving a duplicate' do
        existing_login_code = create(:login_code)
        expect(existing_login_code).to be_active

        duplicate_login_code = build(:login_code)
        duplicate_login_code.code = existing_login_code.code

        expect do
          duplicate_login_code.save!
        end.to raise_error(ActiveRecord::RecordNotUnique)
      end
    end

    context 'when an existing code is inactive' do
      it 'saves successfully reusing the same code' do
        existing_login_code = create(:login_code, used_at: Date.current)
        expect(existing_login_code).to_not be_active

        duplicate_login_code = build(:login_code)
        duplicate_login_code.code = existing_login_code.code

        duplicate_login_code.save!

        expect(duplicate_login_code.code).to eq(existing_login_code.code)
      end
    end
  end
end
