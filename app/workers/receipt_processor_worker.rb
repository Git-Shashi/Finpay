class ReceiptProcessorWorker
  include Sidekiq::Worker

  def perform(receipt_id, tenant = nil)
    if tenant.present?
      Apartment::Tenant.switch(tenant) do
        receipt = Receipt.find(receipt_id)
        receipt.process!
      end
    else
      receipt = Receipt.find(receipt_id)
      receipt.process!
    end
  rescue StandardError => e
    Rails.logger.error("ReceiptProcessorWorker failed: #{e.message}")
    raise
  end
end
