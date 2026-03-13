class AddProcessingFieldsToReceipts < ActiveRecord::Migration[7.0]
  def change
    add_column :receipts, :status, :string
    add_column :receipts, :processed_at, :datetime
  end
end
