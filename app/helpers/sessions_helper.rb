module SessionsHelper 

  def sign_in(user)
    session[:user_id] = user.id
    self.current_user = user
    remember user
    Rails.logger.info "Login: User #{user.id}"
  end

  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.digest(user.remember_token)
  end

  def forget(user)
    if user
      user.forget
      cookies.delete(:user_id)
      cookies.delete(:remember_token)
    end
  end

  def sign_out
    forget current_user
    session.delete(:user_id)
    self.current_user = nil
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    elsif cookies.signed[:user_id]
      user = User.find_by(id: cookies.signed[:user_id])
      if user && user.authenticated?(cookies[:remember_token])
        sign_in user
      end
    end

    @current_user
  end

  def signed_in?
    current_user.present?
  end
end
