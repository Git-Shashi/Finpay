class AddAasmStateAndApprovedByToExpenses < ActiveRecord::Migration[7.0]
  def change
    add_column :expenses, :aasm_state, :string, default: "pending", null: false
    add_column :expenses, :approved_by_id, :bigint
    add_index :expenses, :aasm_state
    add_index :expenses, :approved_by_id
  end
end
