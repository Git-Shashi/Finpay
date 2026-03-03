require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(build(:user)).to be_valid
    end

    it 'is invalid without a name' do
      expect(build(:user, name: nil)).not_to be_valid
    end

    it 'is invalid without an email' do
      expect(build(:user, email: nil)).not_to be_valid
    end

    it 'is invalid with a duplicate email' do
      create(:user, email: "test@example.com")
      expect(build(:user, email: "test@example.com")).not_to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to a department' do
      department = create(:department)
      user = create(:user, department: department)
      expect(user.department).to eq(department)
    end

    it 'has many expenses' do
      user = create(:user)
      expense = create(:expense, user: user)
      expect(user.expenses).to include(expense)
    end
  end

  describe 'roles' do
    it 'can be an admin' do
      user = build(:user, role: :admin)
      expect(user.admin?).to be true
    end

    it 'can be an employee' do
      user = build(:user, role: :employee)
      expect(user.employee?).to be true
    end
  end
end