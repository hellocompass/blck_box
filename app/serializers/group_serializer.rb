class GroupSerializer < ActiveModel::Serializer
  attributes :id, :name, :enabled, :created_at

  has_many :contents, each_serializer: ContentSerializer
  has_many :users, each_serializer: UserSerializer
end
