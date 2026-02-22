# frozen_string_literal: true

require 'apartment/elevators/subdomain'

Apartment.configure do |config|
  # Exclude the Company model itself from multi-tenancy
  # because it lives in the public schema and stores tenant info
  config.excluded_models = %w[Company]

  # Dynamically get the tenant names from your Company table
  config.tenant_names = -> { Company.pluck(:schema_name) }

  # If using PostgreSQL schemas (default)
  config.use_schemas = true

  # Optional: persistent schemas you always want in search_path
  # config.persistent_schemas = %w[public]
end

# Setup subdomain-based tenant switching
Rails.application.config.middleware.use Apartment::Elevators::Subdomain