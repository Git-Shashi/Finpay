class User < ApplicationRecord
  # Devise modules
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable

  # Devise Token Auth
  include DeviseTokenAuth::Concerns::User

  # Associations
  belongs_to :department
  has_many :expenses, dependent: :destroy

  # Roles
  enum :role, { admin: 0, employee: 1 }

  # Validations
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
end