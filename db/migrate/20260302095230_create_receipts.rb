class CreateReceipts < ActiveRecord::Migration[7.0]
  def change
    create_table :receipts do |t|
      t.references :expense, null: false, foreign_key: true
      t.string :file_url, null: false
      t.string :file_name, null: false
      t.string :file_type, null: false
      t.decimal :amount, null: false, precision: 10, scale: 2
      t.date :receipt_date, null: false
      t.text :notes

      t.timestamps
    end
  end
end
