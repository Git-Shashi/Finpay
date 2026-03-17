FactoryBot.define do
  factory :expense do
    amount { Faker::Commerce.price(range: 10.0..5000.0) }
    description { Faker::Lorem.sentence }
    expense_date { Faker::Date.backward(days: 30) }
    status { :pending }
    association :user
    association :category

    trait :approved do
      status { :approved }
    end

    trait :rejected do
      status { :rejected }
    end

    trait :reimbursed do
      status { :reimbursed }
    end

    trait :archived do
      status { :archived }
    end
  end
end
