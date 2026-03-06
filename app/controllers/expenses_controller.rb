class ExpensesController < ApplicationController
  before_action :authenticate_user!

  def index
    expenses = Expense.all
    render json: ExpenseSerializer.new(expenses).serialize
  end

  def show
    render json: ExpenseSerializer.new(expense).serialize
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
    expense.update!(expense_params)
    render json: ExpenseSerializer.new(expense).serialize
  end

  def destroy
    expense.destroy
    head :no_content
  end

  private

  def expense
    @expense ||= Expense.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Expense not found' }, status: :not_found
  end

  def expense_params
    params.require(:expense).permit(:category_id, :amount, :description, :expense_date)
  end
end