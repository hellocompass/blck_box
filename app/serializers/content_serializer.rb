class ContentSerializer < ActiveModel::Serializer
  attributes :group_id, :user_ids, :image_url

  def image_url
    object.image.url(:v_540x960)
  end
end
