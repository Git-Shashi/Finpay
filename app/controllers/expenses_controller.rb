class ExpensesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_expense, only: [:show, :update, :destroy]

  def index
    expenses = Expense.all
    render json: ExpenseSerializer.new(expenses).serialize
  end

  def show
    expense = Expense.find(params[:id])
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
    expense = Expense.find(params[:id])
    expense.update!(expense_params)
    render json: ExpenseSerializer.new(expense).serialize
  end

  def destroy
    Expense.find(params[:id]).destroy
    head :no_content
  end

  private

  def set_expense
    @expense = Expense.find(params[:id])
  end

  def expense_params
    params.require(:expense).permit(:category_id, :amount, :description, :expense_date)
  end
end