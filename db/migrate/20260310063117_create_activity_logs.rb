class CreateActivityLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :activity_logs do |t|
      t.bigint :expense_id, null: false
      t.bigint :user_id
      t.string :from_state
      t.string :to_state
      t.text :reason

      t.timestamps
    end

    add_index :activity_logs, :expense_id
    add_index :activity_logs, :user_id

    add_foreign_key :activity_logs, :expenses
    add_foreign_key :activity_logs, :users
  end
end
