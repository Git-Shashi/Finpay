FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    sequence(:email) { |n| "#{Faker::Internet.username}#{n}@example.com" }
    password { 'password123' }
    role { :employee }
    association :department

    trait :admin do
      role { :admin }
    end
  end
end
