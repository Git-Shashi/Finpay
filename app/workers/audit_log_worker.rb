class AuditLogWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5

  def perform(expense_id, action, tenant = nil)
    if tenant.present?
      Apartment::Tenant.switch(tenant) do
        expense = Expense.find(expense_id)
        ActivityLog.create!(expense: expense, action: action)
      end
    else
      expense = Expense.find(expense_id)
      ActivityLog.create!(expense: expense, action: action)
    end
  rescue StandardError => e
    Rails.logger.error("AuditLogWorker failed: #{e.message}")
    raise
  end
end