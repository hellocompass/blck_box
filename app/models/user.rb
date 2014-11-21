class User < ActiveRecord::Base
  has_secure_password

  validate { |user| UsersValidator.validate user }

  before_create :create_remember_token
  before_save { self.email = email.downcase }

  has_many :connections
  has_and_belongs_to_many :groups
  has_and_belongs_to_many :contents
  # has_and_belongs_to_many :roles

  has_many :phone_numbers, dependent: :destroy
  has_many :emails, dependent: :destroy

  def new_remember_token
    SecureRandom.urlsafe_base64
  end

  def digest(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def has_role?(role)
    roles.map(&:name).include?(role)
  end

  def remember
    update_attribute(:remember_token, digest(new_remember_token))
  end

  def forget
    update_attribute(:remember_token, nil)
  end

  def authenticated?(token)
    return false unless remember_token
    digest(remember_token) == token
  end

  private

  def create_remember_token
    self.remember_token = digest(new_remember_token)
  end
end
