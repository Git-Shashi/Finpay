class RemoveOldFileColumnsFromReceipts < ActiveRecord::Migration[7.0]
  def change
    remove_column :receipts, :file_url, :string
    remove_column :receipts, :file_name, :string
    remove_column :receipts, :file_type, :string
  end
end
