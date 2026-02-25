class FixRoleTypeInUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :role, :string
    add_column :users, :role, :integer, null: false, default: 1
  end
end