class AddActionToActivityLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :activity_logs, :action, :string
  end
end