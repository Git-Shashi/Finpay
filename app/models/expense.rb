class Expense < ApplicationRecord
  belongs_to :user
  belongs_to :category

  enum :status, { pending: 0, approved: 1, rejected: 2 }

  validates :amount, :expense_date, presence: true
end
