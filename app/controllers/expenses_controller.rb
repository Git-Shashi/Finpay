class ExpensesController < ApplicationController
  def index
    render json: Expense.all
  end

  def show
    render json: Expense.find(params[:id])
  end

  def create
    expense = current_user.expenses.create!(expense_params)
    render json: expense, status: :created
  end

  def update
    expense = Expense.find(params[:id])
    expense.update!(expense_params)
    render json: expense
  end

  def destroy
    Expense.find(params[:id]).destroy
    head :no_content
  end

  private

  def expense_params
    params.require(:expense).permit(
      :category_id,
      :amount,
      :description,
      :expense_date
    )
  end
end