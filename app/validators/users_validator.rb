class UsersValidator
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  PASSWORD_MIN_LENGTH = 6
  PASSWORD_MAX_LENGTH = 50

  def self.validate(user)
    self.new(user).validate
  end

  def initialize(user)
    @user = user
  end

  def validate
    validate_email if @user.new_record? || @user.email_changed?
    validate_password if @user.new_record? || @user.password.present?

    @user
  end

  private

  def validate_email
    if @user.email.blank?
      @user.errors.add :email, 'can\'t be blank'
    elsif !@user.email.match VALID_EMAIL_REGEX
      @user.errors.add :email, 'looks like it might have a typo'
    elsif User.where(email: @user.email).first
      @user.errors.add :email, 'address is already registered.'
    end
  end

  def validate_password
    if @user.password.blank?
      @user.errors.add :password, 'can\'t be blank'
    elsif @user.password.length < PASSWORD_MIN_LENGTH ||
        @user.password.length > PASSWORD_MAX_LENGTH
      @user.errors.add(
          :password,
          "must be between #{PASSWORD_MIN_LENGTH} and #{PASSWORD_MAX_LENGTH} characters"
      )
    elsif @user.password != @user.password_confirmation
      @user.errors.add :password, 'and confirmation do not match.'
    end
  end
end
