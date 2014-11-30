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
    if @user.email || !@user.pending
      validate_email if @user.new_record? || @user.email_changed?
    else
      validate_phone
    end

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

  def validate_phone
    if @user.phone_numbers.blank?
      @user.errors.add :email, 'or Phone Number is required'
    end
  end

  # NOTE: bcrypt gem adds errors when password and confirmation don't match
  def validate_password
    if @user.password.blank?
      @user.errors.add :password, 'can\'t be blank'
    elsif @user.password_confirmation.blank?
      @user.errors.add(
        :password_confirmation,
        "is needed!"
      )
    elsif @user.password.length < PASSWORD_MIN_LENGTH ||
      @user.password.length > PASSWORD_MAX_LENGTH
      @user.errors.add(
        :password,
        "must be between #{PASSWORD_MIN_LENGTH} and #{PASSWORD_MAX_LENGTH} characters"
      )
    end
  end
end
