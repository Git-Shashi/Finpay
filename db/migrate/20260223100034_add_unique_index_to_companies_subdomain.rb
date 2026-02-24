class AddUniqueIndexToCompaniesSubdomain < ActiveRecord::Migration[7.0]
  def change
    add_index :companies, :subdomain, unique: true
  end
end
