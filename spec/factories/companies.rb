FactoryBot.define do
  factory :company do
    name { Faker::Company.name }
    sequence(:subdomain) { |n| "#{Faker::Internet.domain_word}#{n}" }
    schema_name { subdomain.present? ? "company_#{subdomain.parameterize}" : nil }
  end
end
