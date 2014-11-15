class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include SessionsHelper

  rescue_from ActiveRecord::RecordNotFound, with: :rescue_not_found

  class BlackIn::NotFoundError < StandardError; end
  rescue_from BlackIn::NotFoundError, with: :rescue_not_found

  class BlackIn::Unauthorized < StandardError; end
  rescue_from BlackIn::Unauthorized, with: :rescue_unauthorized

  class BlackIn::BadRequest < StandardError; end
  rescue_from BlackIn::BadRequest, with: :rescue_bad_request

  protected

  # TODO: add custom 404 page here
  def rescue_not_found
    render "#{Rails.root}/public/404.html", status: 404
  end

  # TODO: redirect to login page if no current user
  def rescue_unauthorized
    render nothing: true, status: 403
  end

  def rescue_bad_request
    render nothing: true, status: 400
  end
end
