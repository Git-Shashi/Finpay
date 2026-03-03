require 'rails_helper'

RSpec.describe Expense, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(build(:expense)).to be_valid
    end

    it 'is invalid without an amount' do
      expect(build(:expense, amount: nil)).not_to be_valid
    end

    it 'is invalid without an expense_date' do
      expect(build(:expense, expense_date: nil)).not_to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to a user' do
      user = create(:user)
      expense = create(:expense, user: user)
      expect(expense.user).to eq(user)
    end

    it 'belongs to a category' do
      category = create(:category)
      expense = create(:expense, category: category)
      expect(expense.category).to eq(category)
    end

    it 'has many receipts' do
      expense = create(:expense)
      receipt = create(:receipt, expense: expense)
      expect(expense.receipts).to include(receipt)
    end
  end
end