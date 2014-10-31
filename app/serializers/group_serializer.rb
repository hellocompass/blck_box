class GroupSerializer < ActiveModel::Serializer
  attributes :id, :name, :user_ids

  def user_ids
    object.users.map(&:id)
  end
end
