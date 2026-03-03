class UserSerializer
  include Alba::Resource
  attributes :id, :name, :email, :role
end