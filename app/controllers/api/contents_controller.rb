class Api::ContentsController < ApiController

  before_filter :get_group
  before_filter :authenticate!

  def recent
    raise BlackIn::BadRequest.new unless @group.enabled

    params[:per] ||= 100

    content = @group.contents.recent.page(params[:page]).per(params[:per])
    render json: content, each_serializer: ContentSerializer
  end

  private

  def get_group
    @group = Group.find(params[:group_id])
  end

  def authenticate!
    unless signed_in? && @group.users.include?(current_user)
      raise BlackIn::NotFoundError.new
    end
  end
end
