class ExpenseListSerializer
  def initialize(expenses)
    @expenses = expenses
  end

  def serialize
    @expenses.map do |expense|
      {
        id: expense.id,
        amount: expense.amount,
        description: expense.description,
        expense_date: expense.expense_date,
        status: expense.status,
        category: {
          id: expense.category&.id,
          name: expense.category&.name
        },
        user: {
          id: expense.user&.id,
          name: expense.user&.name
        },
        receipts: expense.receipts.map { |r| { id: r.id, url: r.file_url } }
      }
    end
  end
end