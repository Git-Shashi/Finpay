FactoryBot.define do
  factory :receipt do
    file_url { "http://example.com/receipt.pdf" }
    file_name { "receipt.pdf" }
    file_type { "pdf" }
    amount { 100.0 }
    receipt_date { Date.today }
    notes { "Test receipt" }
    association :expense
  end
end