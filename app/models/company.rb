class Company < ApplicationRecord
  validates :subdomain, presence: true, uniqueness: true
  validates :schema_name, presence: true, uniqueness: true

  before_validation :generate_schema_name, on: :create

  private

  def generate_schema_name
    self.schema_name ||= "company_#{subdomain.parameterize}"
  end
end

