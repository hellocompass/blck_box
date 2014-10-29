class ResetPassword
  PASSWORD_LENGTH = 10

  def self.reset!(email)
    self.new(email).reset!
  end
  
  def initialize(email)
    @user = User.find_by_email(email.to_s)
  end

  def reset!
    raise BlackIn::NotFoundError unless @user

    @password = SecureRandom.urlsafe_base64(PASSWORD_LENGTH)
    update_user && send_reset_email
  end

  private

  def update_user
    @user.update_attributes password: @password, password_confirmation: @password
  end

  def send_reset_email
    ResetPasswordMailer.password_reset @user.email, @password
  end
end
