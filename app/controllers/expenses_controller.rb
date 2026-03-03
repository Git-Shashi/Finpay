class ExpensesController < ApplicationController
  before_action :authenticate_user!

  def index
    render json: ExpenseSerializer.new(Expense.all).serialize
  end

  def show
    render json: ExpenseSerializer.new(Expense.find(params[:id])).serialize
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
    expense = Expense.find(params[:id])
    expense.update!(expense_params)
    render json: ExpenseSerializer.new(expense).serialize
  end

  def destroy
    Expense.find(params[:id]).destroy
    head :no_content
  end

  private

  def expense_params
    params.require(:expense).permit(:category_id, :amount, :description, :expense_date)
  end
end