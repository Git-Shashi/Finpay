class AuditLogWorker
  include Sidekiq::Worker
  include TenantLoader

  sidekiq_options retry: 5

  def perform(expense_id, action, tenant)
    with_tenant(tenant) do
      expense = Expense.find(expense_id)
      ActivityLog.create!(expense: expense, action: action)
    end
  rescue StandardError => e
    Rails.logger.error(I18n.t("errors.worker_failed", worker: self.class.name, message: e.message))
    raise
  end
end
