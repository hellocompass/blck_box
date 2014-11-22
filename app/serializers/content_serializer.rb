class ContentSerializer < ActiveModel::Serializer
  attributes :group_id, :user_ids, :image_url, :created_at

  def image_url
    object.image.url(:v_414x736)
  end
end
