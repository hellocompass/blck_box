class Api::UsersController < ApiController
  before_filter :authenticate!, only: [:show, :update]
  before_filter :find_user, only: [:show, :update]

  def new
    @user = User.new
    render json: @user, status: 200
  end

  def create
    @user = User.where(email: user_params[:email].downcase, pending: true).first
    create_proc = get_create_proc

    redirect_or_err @user, :api_user_path, 400, &create_proc
  end

  def update
    redirect_or_err(@user, :api_user_path, 400) do
      @user.update_attributes user_params
    end
  end

  def show
    render json: @user, status: 200, serializer: UserSerializer
  end

  def reset_password
    begin
      ResetPassword.reset! params[:email]
      render json: {}, status: 200
    rescue BlackIn::NotFoundError => e
      render json:  { errors: ['User with that email does not exist']  }, status: 404
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :email,
      :password,
      :password_confirmation,
      :username,
      :pending
    )
  end

  def find_user
    @user = User.find params[:id]
  end

  def authenticate!
    unless signed_in? && current_user.id == params[:id].to_i
      raise BlackIn::NotFoundError.new
    end
  end

  def get_create_proc
    if @user
      Proc.new do
        @user.update_attributes(user_params.merge(pending: false)) &&
          sign_in(@user)
      end
    else
      @user = User.new(user_params)
      Proc.new { CreateUser.create(@user).persisted? && sign_in(@user) }
    end
  end
end
