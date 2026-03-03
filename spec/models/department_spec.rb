require 'rails_helper'

RSpec.describe Department, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(build(:department)).to be_valid
    end

    it 'is invalid without a name' do
      expect(build(:department, name: nil)).not_to be_valid
    end
  end

  describe 'associations' do
    it 'has many users' do
      department = create(:department)
      user = create(:user, department: department)
      expect(department.users).to include(user)
    end
  end
end