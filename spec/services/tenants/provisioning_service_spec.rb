require 'rails_helper'

RSpec.describe Tenants::ProvisioningService, type: :service do
  let(:company) { build(:company, subdomain: 'newcorp', schema_name: 'company_newcorp') }
  let(:service) { described_class.new(company) }

  before do
    allow(Apartment::Tenant).to receive(:create)
    allow(Apartment::Tenant).to receive(:switch).with(company.schema_name).and_yield
    allow(ActiveRecord::Schema).to receive(:verbose=)
    allow(service).to receive(:load)
  end

  

  describe '#call' do
    it 'creates a new apartment tenant for the company' do
      service.call
      expect(Apartment::Tenant).to have_received(:create).with(company.schema_name)
    end

    it 'switches into the new tenant schema' do
      service.call
      expect(Apartment::Tenant).to have_received(:switch).with(company.schema_name)
    end

    it 'loads the schema inside the tenant context' do
      schema_path = Rails.root.join('db/schema.rb')
      service.call
      expect(service).to have_received(:load).with(schema_path)
    end

    it 'suppresses schema load output' do
      service.call
      expect(ActiveRecord::Schema).to have_received(:verbose=).with(false)
    end
  end
end
