RSpec.shared_context 'swagger auth' do
  before { Apartment::Tenant.switch!('company_beta') }
  after  { Apartment::Tenant.reset }

  let(:auth_user) { create(:user, :admin) }

  let(:auth_response_headers) do
    auth_user
    post '/api/v1/auth/sign_in',
         params: { email: auth_user.email, password: 'password123' },
         headers: { 'X-Company-Id' => 'beta' }
    response.headers.to_h
  end

  let(:'access-token') { auth_response_headers['access-token'] }
  let(:client)         { auth_response_headers['client'] }
  let(:uid)            { auth_response_headers['uid'] }
  let(:'X-Company-Id') { 'beta' }
end
