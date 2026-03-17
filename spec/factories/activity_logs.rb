FactoryBot.define do
  factory :activity_log do
    action { 'created' }
    association :expense
    association :user
  end
end
