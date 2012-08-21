class Message
  include Mongoid::Document

  field :author
  field :message
  field :date

end
