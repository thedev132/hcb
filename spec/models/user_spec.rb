# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  fixtures 'users'

  let(:user) { users(:user1) }

  it 'is valid' do
    expect(user).to be_valid
  end

  it 'is admin' do
    expect(user).to be_admin
  end

  describe '#initials' do
    context 'when missing name' do
      before do
        user.full_name = nil
        user.save!
      end

      it 'returns initials from email' do
        expect(user.initials).to eql('U')
      end
    end
  end

  describe '#initial_name' do
    before do
      user.full_name = 'First Last'
    end

    it 'returns' do
      expect(user.initial_name).to eql('First L')
    end

    context 'when first name is missing' do
      before do
        user.full_name = 'Last'
      end

      it 'returns' do
        expect(user.initial_name).to eql('Last L')
      end
    end

    context 'when last name is missing' do
      before do
        user.full_name = 'First'
      end

      it 'returns' do
        expect(user.initial_name).to eql('First F')
      end
    end

    context 'when full_name is nil' do
      before do
        user.full_name = nil
      end

      it 'returns' do
        expect(user.initial_name).to eql('user1 u')
      end
    end
  end
end

