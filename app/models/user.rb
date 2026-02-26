class User < ApplicationRecord
  belongs_to :department
  has_many :expenses, dependent: :destroy

  enum :role, { admin: 0, employee: 1 }

  validates :name, :email, presence: true
  validates :email, uniqueness: true

  devise :database_authenticatable,
         :registerable,
         :jwt_authenticatable,
         jwt_revocation_strategy: JwtDenylist
end
