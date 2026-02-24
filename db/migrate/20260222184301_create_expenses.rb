class CreateExpenses < ActiveRecord::Migration[7.0]
  def change
    create_table :expenses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.decimal :amount
      t.text :description
      t.date :expense_date
      t.integer :status
      t.datetime :resolved_at

      t.timestamps
    end
  end
end
