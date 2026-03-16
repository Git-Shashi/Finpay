require 'rails_helper'

RSpec.describe Receipt, type: :model do
  describe 'associations' do
    it 'belongs to an expense' do
      expense = create(:expense)
      receipt = create(:receipt, expense: expense)
      expect(receipt.expense).to eq(expense)
    end

    it 'can have an attached file' do
      receipt = create(:receipt)
      expect(receipt.file).to be_attached
    end
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(build(:receipt)).to be_valid
    end

    it 'is invalid without an amount' do
      expect(build(:receipt, amount: nil)).not_to be_valid
    end

    it 'is invalid without a receipt_date' do
      expect(build(:receipt, receipt_date: nil)).not_to be_valid
    end

    it 'is invalid with a non-positive amount' do
      expect(build(:receipt, amount: 0)).not_to be_valid
      expect(build(:receipt, amount: -10)).not_to be_valid
    end
  end
end
