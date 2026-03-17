require 'rails_helper'

RSpec.describe Company, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(build(:company)).to be_valid
    end

    it 'is invalid without a subdomain' do
      expect(build(:company, subdomain: nil)).not_to be_valid
    end

    it 'is invalid with a duplicate subdomain' do
      create(:company, subdomain: 'acme', schema_name: 'company_acme')
      expect(build(:company, subdomain: 'acme', schema_name: 'company_acme2')).not_to be_valid
    end

    it 'is invalid with a duplicate schema_name' do
      create(:company, subdomain: 'acme1', schema_name: 'company_acme')
      expect(build(:company, subdomain: 'acme2', schema_name: 'company_acme')).not_to be_valid
    end
  end

  describe 'callbacks' do
    it 'generates schema_name from subdomain before validation' do
      company = build(:company, subdomain: 'testcorp', schema_name: nil)
      company.valid?
      expect(company.schema_name).to eq('company_testcorp')
    end

    it 'does not override an already set schema_name' do
      company = build(:company, subdomain: 'testcorp', schema_name: 'custom_schema')
      company.valid?
      expect(company.schema_name).to eq('custom_schema')
    end

    it 'parameterizes subdomain with spaces into schema_name' do
      company = build(:company, subdomain: 'test corp', schema_name: nil)
      company.valid?
      expect(company.schema_name).to eq('company_test-corp')
    end
  end
end
