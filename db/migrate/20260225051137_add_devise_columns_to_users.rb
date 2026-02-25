def change
  change_table :users, bulk: true do |t|
    t.string   :encrypted_password, null: false, default: ""
    t.string   :reset_password_token
    t.datetime :reset_password_sent_at
  end
end
