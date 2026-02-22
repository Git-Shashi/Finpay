
#Tenant creation and schema loading are encapsulated in a service object.
#This service creates a new tenant (schema) for the company and loads the database schema into it.
#The Apartment gem is used to manage multi-tenancy, and the service ensures that each tenant has its own isolated database schema.
#The load_schema method reads the schema.rb file and executes its contents to set up the database structure for the new tenant.
# This service can be called after a new company is created to provision the tenant for that company.


module Tenants
  class ProvisioningService
    def initialize(company)
      @company = company
    end

    def call
      Apartment::Tenant.create(@company.schema_name)

      Apartment::Tenant.switch(@company.schema_name) do
        load_schema
      end
    end

    private

    def load_schema
      schema_path = Rails.root.join('db/schema.rb')
      ActiveRecord::Base.connection.execute(File.read(schema_path))
    end
  end
end