class AuditLogWorker
  include Sidekiq::Worker

  sidekiq_options retry: 5

  def perform(expense_id, action, tenant)
    raise ArgumentError, I18n.t("audit_log_worker.errors.tenant_required") if tenant.blank?

    Apartment::Tenant.switch(tenant) do
      expense = Expense.find(expense_id)
      ActivityLog.create!(expense: expense, action: action)
    end
  rescue StandardError => e
    Rails.logger.error((I18n.t("audit_log_worker.errors.failed", message: e.message)))
    raise
  end
end
