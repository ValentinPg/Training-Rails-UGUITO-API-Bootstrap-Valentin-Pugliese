class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :document_number
end
