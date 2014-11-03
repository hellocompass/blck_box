class Api::GroupsController < ApiController

  before_filter :find_group, only: [:show, :update]
  before_filter :verify_logged_in, only: [:create]
  before_filter :authenticate!, only: [:show, :update]

  def show
    serializer = @group.enabled ? GroupSerializer : InactiveGroupSerializer
    render json: @group, status: 200, serializer: serializer
  end

  def create
    @group = Group.new

    redirect_or_err @group, :api_group_path, 400 do
      SaveGroup.save(@group, group_params)
    end
  end

  def update
    redirect_or_err @group, :api_group_path, 400 do
      SaveGroup.save(@group, group_params)
    end
  end

  private

  def find_group
    @group = Group.find(params[:id])
  end

  def group_params
    group_attrs = params.require(:group).permit(:name, :user_ids)
    group_attrs[:user_ids] ||= []
    group_attrs[:user_ids] << current_user.id

    group_attrs
  end

  def authenticate!
    unless signed_in? && current_user.groups.where(id: params[:id]).first
      raise BlackIn::NotFoundError.new
    end
  end
end
