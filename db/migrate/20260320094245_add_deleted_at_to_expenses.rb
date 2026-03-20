class AddDeletedAtToExpenses < ActiveRecord::Migration[7.0]
  def change
    add_column :expenses, :deleted_at, :datetime
  end
end
