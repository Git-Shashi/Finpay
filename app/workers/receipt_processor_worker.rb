class ReceiptProcessorWorker
  include Sidekiq::Worker

  def perform(receipt_id)
    receipt = Receipt.find(receipt_id)
    # Add your processing logic here
    receipt.process!
  end
end