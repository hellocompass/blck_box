class GroupsUser
  validates_uniqueness_of :user_id, scope: :group_id
end
