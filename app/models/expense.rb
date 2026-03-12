require 'aasm'

class Expense < ApplicationRecord
  belongs_to :user
  belongs_to :category
  has_many :receipts, dependent: :destroy
  has_many :activity_logs, dependent: :destroy
  belongs_to :approved_by, class_name: 'User', optional: true

  validates :amount, :expense_date, presence: true
  validates :amount, numericality: { greater_than: 0 }
  scope :by_category, ->(category_id) { where(category_id: category_id) }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_date_range, ->(start_date, end_date) { where(expense_date: start_date..end_date) }

  include AASM

  aasm column: :status do
    state :pending, initial: true
    state :approved
    state :rejected
    state :reimbursed
    state :archived

    event :approve do
      transitions from: :pending, to: :approved
    end

    event :reject do
      transitions from: :pending, to: :rejected
    end

    event :reimburse do
      transitions from: :approved, to: :reimbursed
    end

    event :archive do
      transitions from: [:pending, :approved, :rejected, :reimbursed], to: :archived
    end
  end

  def record_transition(from_state, to_state, reason = nil)
    ActivityLog.create!(
      expense: self,
      user: approved_by,
      from_state: from_state,
      to_state: to_state,
      reason: reason
    )
  end
end