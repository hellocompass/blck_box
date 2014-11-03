class GroupSerializer < ActiveModel::Serializer
  attributes :id, :name, :user_ids, :enabled, :created_at

  has_many :contents, each_serializer: ContentSerializer

  def user_ids
    object.users.map(&:id)
  end
end
