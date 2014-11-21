class Api::AppController < ApiController

  def bootstrap
    data = {
      current_user: UserSerializer.new(current_user)
    }

    render json: data, status: 200
  end
end
