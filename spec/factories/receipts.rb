FactoryBot.define do
  factory :receipt do
    amount { 100.0 }
    receipt_date { Time.zone.today }
    notes { "Test receipt" }
    association :expense

    after(:build) do |receipt|
      receipt.file.attach(
        io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test.pdf')),
        filename: 'test.pdf',
        content_type: 'application/pdf'
      )
    end
  end
end
