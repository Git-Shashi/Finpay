class UpdateExpensesForAasm < ActiveRecord::Migration[7.0]
  def change
    remove_index :expenses, :aasm_state
    remove_column :expenses, :aasm_state, :string
    change_column :expenses, :status, :string
  end
end
