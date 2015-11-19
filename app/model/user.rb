class User

  include DataMapper::Resource
  property :id, Serial
  property :login, String
  property :name, String
  property :email, String
  property :pair, String

end
