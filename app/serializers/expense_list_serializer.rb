class ExpenseListSerializer
  include Alba::Resource

  attributes :id, :amount, :description, :expense_date, :status

  one :category do
    attributes :id, :name
  end

  one :user do
    attributes :id, :name
  end

  many :receipts do
    attribute :id
    attribute :url do |receipt|
      receipt.file_url
    end
  end
end