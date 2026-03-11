class ExpenseSerializer
  include Alba::Resource

  attributes :id, :amount, :description, :expense_date, :aasm_state, :resolved_at

  

  association :user, serializer: UserSerializer
  association :category, serializer: CategorySerializer
  association :receipts, serializer: ReceiptSerializer
end
