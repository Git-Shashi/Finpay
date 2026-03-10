class ExpenseListSerializer
  include Alba::Resource

  attributes :id, :amount, :description, :expense_date, :aasm_state

  one :category do
    attributes :id, :name
  end

  one :user do
    attributes :id, :name
  end

  many :receipts do
    attributes :id

    attribute :url, &:file_url
  end
end
