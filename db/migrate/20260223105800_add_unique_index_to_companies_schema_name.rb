class AddUniqueIndexToCompaniesSchemaName < ActiveRecord::Migration[7.0]
  def change
    add_index :companies, :schema_name, unique: true
  end
end
