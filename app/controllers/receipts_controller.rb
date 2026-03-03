class ReceiptsController < ApplicationController
  before_action :authenticate_user!

  def index
    render json: ReceiptSerializer.new(Receipt.all).serialize
  end

  def create
    expense = current_user.expenses.find(params[:expense_id])
    receipt = expense.receipts.create!(receipt_params)
    render json: ReceiptSerializer.new(receipt).serialize, status: :created
  end

  def destroy
    Receipt.find(params[:id]).destroy
    head :no_content
  end

  private

  def receipt_params
    params.require(:receipt).permit(:file_url, :file_name, :file_type, :amount, :receipt_date, :notes)
  end
end
