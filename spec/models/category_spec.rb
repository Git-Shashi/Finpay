require 'rails_helper'

RSpec.describe Category, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(build(:category)).to be_valid
    end

    it 'is invalid without a name' do
      expect(build(:category, name: nil)).not_to be_valid
    end

    it 'is invalid with a duplicate name' do
      create(:category, name: "Travel")
      expect(build(:category, name: "Travel")).not_to be_valid
    end
  end

  describe 'associations' do
    it 'has many expenses' do
      category = create(:category)
      expense = create(:expense, category: category)
      expect(category.expenses).to include(expense)
    end
  end
end
