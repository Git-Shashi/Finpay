class ReceiptProcessorWorker
  include Sidekiq::Worker

  def perform(expense_id, receipt_id, tenant)
    raise ArgumentError, I18n.t("receipt_processor_worker.errors.tenant_required") if tenant.blank?

    Apartment::Tenant.switch(tenant) do
      expense = Expense.find(expense_id)
      receipt = expense.receipts.find(receipt_id)
      receipt.process!
    end
  rescue StandardError => e
    Rails.logger.error((I18n.t("receipt_processor_worker.errors.failed", message: e.message)))
    raise
  end
end
