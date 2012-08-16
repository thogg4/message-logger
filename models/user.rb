class User
  include Mongoid::Document

  field :key
  field :secret
  field :username
  field :hash

end
