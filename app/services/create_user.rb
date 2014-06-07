class CreateUser

  def self.create(user, options = {})
    self.new(user, options).create
  end

  def initialize(user, options = {})
    @user = user
  end

  def create
    send_welcome_email if @user.save
    @user
  end

  private

  def send_welcome_email
    WelcomeMailer.welcome(@user).deliver
  end
end
