class FixRoleTypeInUsers < ActiveRecord::Migration[7.0]
  def up
    change_table :users, bulk: true do |t|
      t.remove  :role
      t.integer :role, null: false, default: 1
    end
  end

  def down
    change_table :users, bulk: true do |t|
      t.remove  :role
      t.string  :role
    end
  end
end
