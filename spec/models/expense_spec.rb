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

    it 'is invalid with a non-positive amount' do
      expect(build(:expense, amount: 0)).not_to be_valid
      expect(build(:expense, amount: -50)).not_to be_valid
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

    it 'destroys receipts on delete' do
      expense = create(:expense)
      create(:receipt, expense: expense)
      expect { expense.destroy }.to change(Receipt, :count).by(-1)
    end
  end

  describe 'AASM state machine' do
    it 'starts in pending state' do
      expect(build(:expense)).to be_pending
    end

    it 'transitions from pending to approved' do
      expense = create(:expense)
      expense.approve!
      expect(expense).to be_approved
    end

    it 'transitions from pending to rejected' do
      expense = create(:expense)
      expense.reject!
      expect(expense).to be_rejected
    end

    it 'transitions from approved to reimbursed' do
      expense = create(:expense, :approved)
      expense.reimburse!
      expect(expense).to be_reimbursed
    end

    it 'transitions from pending to archived' do
      expense = create(:expense)
      expense.archive!
      expect(expense).to be_archived
    end

    it 'cannot be approved from rejected state' do
      expense = create(:expense, :rejected)
      expect { expense.approve! }.to raise_error(AASM::InvalidTransition)
    end

    it 'cannot be reimbursed from pending state' do
      expense = create(:expense)
      expect { expense.reimburse! }.to raise_error(AASM::InvalidTransition)
    end
  end

  describe 'scopes' do
    it 'filters by category' do
      category = create(:category)
      expense = create(:expense, category: category)
      create(:expense)
      expect(Expense.by_category(category.id)).to contain_exactly(expense)
    end

    it 'filters by status' do
      approved = create(:expense, :approved)
      create(:expense)
      expect(Expense.by_status('approved')).to contain_exactly(approved)
    end

    it 'filters by date range' do
      expense = create(:expense, expense_date: '2026-03-10')
      create(:expense, expense_date: '2026-02-01')
      expect(Expense.by_date_range('2026-03-01', '2026-03-31')).to contain_exactly(expense)
    end
  end

  describe '#record_transition' do
    it 'creates an activity log entry' do
      expense = create(:expense)
      expect {
        expense.record_transition('pending', 'approved')
      }.to change(ActivityLog, :count).by(1)
    end

    it 'stores from_state, to_state and reason in the log' do
      expense = create(:expense)
      expense.record_transition('pending', 'approved', 'looks good')
      log = ActivityLog.last
      expect(log.from_state).to eq('pending')
      expect(log.to_state).to eq('approved')
      expect(log.reason).to eq('looks good')
    end
  end
end
