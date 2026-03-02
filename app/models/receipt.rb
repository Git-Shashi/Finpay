class Receipt < ApplicationRecord
  belongs_to :expense

  validates :file_url, :file_name, :file_type, :amount, :receipt_date, presence: true
  validates :amount, numericality: { greater_than: 0 }
end
