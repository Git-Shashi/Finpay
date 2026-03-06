class ReceiptsController < ApplicationController
  before_action :authenticate_user!

  def index
    receipts = Receipt.all
    render json: ReceiptSerializer.new(receipts).serialize
  end

  def show
    if receipt
      render json: ReceiptSerializer.new(receipt).serialize
    else
      render json: { error: 'Receipt not found' }, status: :not_found
    end
  end

  def create
    expense = current_user.expenses.find(params[:expense_id])
    receipt = expense.receipts.create!(receipt_params)
    render json: ReceiptSerializer.new(receipt).serialize, status: :created
  end

  def destroy
    if receipt
      receipt.destroy
      head :no_content
    else
      render json: { error: 'Receipt not found' }, status: :not_found
    end
  end

  private

  def receipt
  @receipt ||= Receipt.find(id: params[:id])
  end

  def receipt_params
    params.require(:receipt).permit(:file_url, :file_name, :file_type, :amount, :receipt_date, :notes)
  end
end
