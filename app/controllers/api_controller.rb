class ApiController < ApplicationController
  protect_from_forgery with: :exception
  respond_to :json
  layout false

  before_filter :corsify

  after_action :set_csrf_headers

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
      render json: { errors: errors.uniq }, status: error_code
    end
  end

  def verify_logged_in
    unless signed_in?
      raise BlackIn::Unauthorized.new
    end
  end

  def redirect_to(url, options = {})
    corsify
    super url, options
  end

  def corsify
    response.headers['Access-Control-Expose-Headers'] = 'X-CSRF-Param, X-CSRF-Token'
    response.headers['Access-Control-Allow-Origin'] = Rails.env == 'production' ? 'http://blck.in' : 'http://localhost:3030'
    response.headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    response.headers['Access-Control-Request-Method'] = 'POST, PUT, DELETE, GET, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization, X-CSRF-Param, X-CSRF-Token'
    response.headers['Access-Control-Allow-Credentials'] = 'true'
  end

  def set_csrf_headers
    return if response.status == 302
    token = form_authenticity_token
    param = request_forgery_protection_token.to_s
    response.body = JSON.parse(response.body).merge({ csrf_param: param, csrf_token: token }).to_json
    response.headers['X-CSRF-Param'] = param
    response.headers['X-CSRF-Token'] = token
  end
end
