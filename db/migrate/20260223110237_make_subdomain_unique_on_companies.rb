class MakeSubdomainUniqueOnCompanies < ActiveRecord::Migration[7.0]
  def change
    remove_index :companies, :subdomain
    add_index :companies, :subdomain, unique: true
  end
end
