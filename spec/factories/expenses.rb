FactoryBot.define do
  factory :expense do
    amount { 100.0 }
    description { "Test expense" }
    expense_date { Time.zone.today }
    status { :pending }
    association :user
    association :category
  end
end
