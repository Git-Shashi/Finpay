class ExpenseSerializer
  include Alba::Resource

  attributes :id, :amount, :description, :expense_date, :aasm_state, :resolved_at

  attribute :available_transitions do |expense|
    expense.aasm.events(permitted: true).map(&:name)
  end

  association :user, serializer: UserSerializer
  association :category, serializer: CategorySerializer
  association :receipts, serializer: ReceiptSerializer
end