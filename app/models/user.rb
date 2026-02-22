class User < ApplicationRecord
  belongs_to :department
  has_many :expenses

  enum role: { admin: 0, employee: 1 }

  validates :name, :email, presence: true
end