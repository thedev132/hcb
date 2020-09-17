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
      end

      it 'returns initials from email' do
        expect(user.initials).to eql('U')
      end
    end
  end

  describe '#safe_name' do
    context 'when initial name is really long' do
      before do
        user.full_name = 'Thisisareallyreallylongfirstnamethatembursewillnotlike Last'
      end

      it 'returns safe_name max of 20 chars' do
        expect(user.safe_name).to eql('Thisisareallyreall L')
        expect(user.safe_name.length).to eql(20)
      end
    end
  end

  describe '#first_name' do
    before do
      user.full_name = 'First Last'
    end

    context 'when name is downcased' do
      before do
        user.full_name = 'ann marie'
      end

      it 'returns' do
        expect(user.first_name).to eql('ann')
      end
    end

    context 'when multiple first names' do
      before do
        user.full_name = 'Prof. Donald Ervin Knuth'
      end

      it 'returns actual first name' do
        expect(user.first_name).to eql('Donald')
      end
    end

    context 'when name entered with comma' do
      before do
        user.full_name = 'Turing, Alan M.'
      end

      it 'returns actual first name' do
        expect(user.first_name).to eql('Alan')
      end
    end
  end

  describe '#last_name' do
    before do
      user.full_name = 'Ken Griffey Jr.'
    end

    it 'returns actual last name' do
      expect(user.last_name).to eql('Griffey')
    end

    context 'when name is downcased' do
      before do
        user.full_name = 'ann marie'
      end

      it 'returns' do
        expect(user.last_name).to eql('marie')
      end
    end

    context 'when entered with comma' do
      before do
        user.full_name = 'Carreño Quiñones, María-Jose'
      end

      it 'returns actual last name' do
        expect(user.last_name).to eql('Quiñones')
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

