module TenantLoader
  def with_tenant(tenant)
    raise TenantNotFoundError, I18n.t("errors.tenant_required") if tenant.blank?

    Apartment::Tenant.switch(tenant) { yield }
  end
end
