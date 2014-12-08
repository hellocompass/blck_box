class InactiveGroupSerializer < ActiveModel::Serializer
  root :group

  attributes :id, :name, :enabled, :created_at

  has_many :users, each_serializer: UserSerializer
end
