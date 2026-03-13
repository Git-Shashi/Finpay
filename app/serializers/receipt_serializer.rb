class ReceiptSerializer
  include Alba::Resource
  include Rails.application.routes.url_helpers

  attributes :id, :amount, :receipt_date, :notes, :status, :processed_at

  attribute :file_url do |receipt|
    rails_blob_path(receipt.file, only_path: true) if receipt.file.attached?
  end
end
