class Email < ActiveRecord::Base
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  belongs_to :user

  validates :email, format: { with: VALID_EMAIL_REGEX, message: 'invalid email bro' }

  before_validation :sanitize_email
  after_validation :enforce_preferred_constraint

  def self.valid_format?(email_address)
    email_address.to_s.downcase.match VALID_EMAIL_REGEX
  end

  private

  def sanitize_email
    self.email = email.downcase
  end

  def enforce_preferred_constraint
    return unless preferred

    current_preferreds = Email.where(user_id: user_id, preferred: true)
    current_preferreds = current_preferreds.where('id != ?', id) if id

    current_preferreds.update_all(preferred: false) if current_preferreds.present?
  end
end
