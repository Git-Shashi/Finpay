FactoryBot.define do
  factory :receipt do
    amount { Faker::Commerce.price(range: 10.0..1000.0) }
    receipt_date { Faker::Date.backward(days: 30) }
    notes { Faker::Lorem.sentence }
    association :expense

    after(:build) do |receipt|
      receipt.file.attach(
        io: Rails.root.join('spec/fixtures/files/test.pdf').open,
        filename: 'test.pdf',
        content_type: 'application/pdf'
      )
    end
  end
end
