require 'rails_helper'

RSpec.describe Receipt, type: :model do
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

  describe '#process!' do
    it 'sets status to processed' do
      receipt = create(:receipt)
      receipt.process!
      expect(receipt.reload.status).to eq('processed')
    end

    it 'sets processed_at timestamp' do
      receipt = create(:receipt)
      expect { receipt.process! }.to change { receipt.reload.processed_at }.from(nil)
    end

    it 'returns true on success' do
      receipt = create(:receipt)
      expect(receipt.process!).to be true
    end
  end
end
