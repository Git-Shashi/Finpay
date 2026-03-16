class ReceiptProcessorWorker
  include Sidekiq::Worker
  include TenantLoader

  def perform(expense_id, receipt_id, tenant)
    with_tenant(tenant) do
      expense = Expense.find(expense_id)
      receipt = expense.receipts.find(receipt_id)
      receipt.process!
    end
  rescue StandardError => e
    Rails.logger.error(I18n.t("errors.worker_failed", worker: self.class.name, message: e.message))
    raise
  end
end
