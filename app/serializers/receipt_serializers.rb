class ReceiptSerializer
  include Alba::Resource
  attributes :id, :file_url, :file_name, :file_type, :amount, :receipt_date, :notes
end