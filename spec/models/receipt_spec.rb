require 'rails_helper'

RSpec.describe Receipt, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(build(:receipt)).to be_valid
    end

    it 'is invalid without a file_url' do
      expect(build(:receipt, file_url: nil)).not_to be_valid
    end

    it 'is invalid without a file_name' do
      expect(build(:receipt, file_name: nil)).not_to be_valid
    end

    it 'is invalid without a file_type' do
      expect(build(:receipt, file_type: nil)).not_to be_valid
    end

    it 'is invalid without an amount' do
      expect(build(:receipt, amount: nil)).not_to be_valid
    end

    it 'is invalid without a receipt_date' do
      expect(build(:receipt, receipt_date: nil)).not_to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to an expense' do
      expense = create(:expense)
      receipt = create(:receipt, expense: expense)
      expect(receipt.expense).to eq(expense)
    end
  end
end