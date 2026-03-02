class Expense < ApplicationRecord
  belongs_to :user
  belongs_to :category
  has_many :receipts, dependent: :destroy

  enum :status, { pending: 0, approved: 1, rejected: 2 }

  validates :amount, :expense_date, :category, presence: true
end
