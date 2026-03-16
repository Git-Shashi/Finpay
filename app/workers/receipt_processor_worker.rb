class ReceiptProcessorWorker
  include Sidekiq::Worker

  def perform(expense_id, receipt_id, tenant)
    raise ArgumentError, "Tenant is required" if tenant.blank?

    Apartment::Tenant.switch(tenant) do
      expense = Expense.find(expense_id)
      receipt = expense.receipts.find(receipt_id)
      receipt.process!
    end
  rescue StandardError => e
    Rails.logger.error("ReceiptProcessorWorker failed: #{e.message}")
    raise
  end
end
