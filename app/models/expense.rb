class Expense < ApplicationRecord
  belongs_to :user
  belongs_to :category
  has_many :receipts, dependent: :destroy

  enum :status, { pending: 0, approved: 1, rejected: 2 }

  validates :amount, :expense_date, presence: true
  validates :amount, numericality: { greater_than: 0 }
  scope :by_category, ->(category_id) { where(category_id: category_id) }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_date_range, ->(start_date, end_date) { where(expense_date: start_date..end_date) }

end
