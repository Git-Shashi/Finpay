require 'rails_helper'

RSpec.describe ActivityLog, type: :model do
  describe 'associations' do
    it 'belongs to an expense' do
      expense = create(:expense)
      log = create(:activity_log, expense: expense)
      expect(log.expense).to eq(expense)
    end

    it 'belongs to a user optionally' do
      log = create(:activity_log, user: nil)
      expect(log).to be_valid
      expect(log.user).to be_nil
    end

    it 'can belong to a user' do
      user = create(:user)
      log = create(:activity_log, user: user)
      expect(log.user).to eq(user)
    end
  end

  describe 'creation' do
    it 'stores action field' do
      log = create(:activity_log, action: 'approved')
      expect(log.action).to eq('approved')
    end

    it 'stores from_state and to_state' do
      log = create(:activity_log, from_state: 'pending', to_state: 'approved')
      expect(log.from_state).to eq('pending')
      expect(log.to_state).to eq('approved')
    end

    it 'stores reason' do
      log = create(:activity_log, reason: 'budget approved')
      expect(log.reason).to eq('budget approved')
    end
  end
end
