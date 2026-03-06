class ExpensesController < ApplicationController
  before_action :authenticate_user!

  def index
    expenses = Expense.all
    render json: ExpenseSerializer.new(expenses).serialize
  end

  def show
    if expense
      render json: ExpenseSerializer.new(expense).serialize
    else
      render json: { error: 'Expense not found' }, status: :not_found
    end
  end

  def create
    expense = current_user.expenses.build(expense_params)
    if expense.save
      render json: ExpenseSerializer.new(expense).serialize, status: :created
    else
      render json: { errors: expense.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if expense
      expense.update!(expense_params)
      render json: ExpenseSerializer.new(expense).serialize
    else
      render json: { error: 'Expense not found' }, status: :not_found
    end
  end

  def destroy
    if expense
      expense.destroy
      head :no_content
    else
      render json: { error: 'Expense not found' }, status: :not_found
    end
  end

  private

  def expense
    return @expense if defined?(@expense)

    @expense = Expense.find_by(id: params[:id])
  end

  def expense_params
    params.require(:expense).permit(:category_id, :amount, :description, :expense_date)
  end
end