class ApiController < ApplicationController
  protect_from_forgery with: :null_session
  respond_to :json
  layout false

  protected

  def rescue_not_found
    render nothing: true, status: 404
  end

  private
 
  def redirect_or_err(model, path, error_code, path_params = nil, &block)
    if block.call
      redirect_to send(path.to_sym, path_params || model.id)
    else
      errors = model ? model.errors.full_messages : []
      render json: { errors: errors }, status: error_code
    end
  end

  def verify_logged_in
    unless signed_in?
      raise BlackIn::Unauthorized.new
    end
  end
end
