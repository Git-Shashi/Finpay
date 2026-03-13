class ReceiptsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_expense

  def index
    render json: ReceiptSerializer.new(expense.receipts).serialize
  end

  def show
    if receipt
      render json: ReceiptSerializer.new(receipt).serialize
    else
      render json: { error: 'Receipt not found' }, status: :not_found
    end
  end

  def create
    receipt = expense.receipts.create!(receipt_params)
    ReceiptProcessorWorker.perform_async(receipt.id)
    render json: ReceiptSerializer.new(receipt).serialize, status: :created
  end

  def destroy
    receipt = expense.receipts.find(params[:id])
    receipt.destroy
    head :no_content
  end

  private

  def set_expense
    @expense = current_user.expenses.find(params[:expense_id])
  end

  def expense
    @expense
  end

  def receipt
    @receipt ||= Receipt.find(params[:id])
  end

  def receipt_params
    params.require(:receipt).permit(:file, :amount, :receipt_date, :notes)
  end
end
