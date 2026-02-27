class DropRefreshTokens < ActiveRecord::Migration[7.0]
  def change
    drop_table :refresh_tokens
  end
end
