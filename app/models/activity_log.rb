class ActivityLog < ApplicationRecord
  belongs_to :expense
  belongs_to :user, optional: true

  validates :from_state, :to_state, presence: true
end