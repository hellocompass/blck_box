class InactiveGroupSerializer < ActiveModel::Serializer
  root :group

  attributes :id, :name, :user_ids, :enabled, :created_at

  def user_ids
    object.users.map(&:id)
  end
end
