class PhoneNumber < ActiveRecord::Base

  belongs_to :user

  before_validation :normalize_self
  validate :number_format

  after_validation :enforce_preferred_constraint

  def self.normalize_numbers(numbers)
    numbers.map do |number|
      self.normalize_number number
    end.compact
  end

  def self.normalize_number(number)
    nums = number.to_s.scan(/\d+/)
    nums.present? ? nums.join('').to_i : nil
  end

  def self.valid_format?(number)
    self.normalize_number(number).to_s.length > 9
  end

  private

  def normalize_self
    self.phone_number = self.class.normalize_number(phone_number)
  end

  def number_format
    unless phone_number.to_s.length > 9
      errors.add :phone_number, 'is not valid'
    end
  end

  def enforce_preferred_constraint
    return unless preferred

    current_preferreds = PhoneNumber.where(user_id: user_id, preferred: true)
    current_preferreds = current_preferreds.where('id != ?', id) if id

    update_preferred(current_preferreds) if current_preferreds.present?
  end

  def update_preferred(numbers)
    mobiles = numbers.any? { |num| num.number_type == 'mobile' }

    if !mobiles || (mobiles && number_type == 'mobile')
      numbers.update_all(preferred: false)
    else
      self.preferred = false
    end
  end
end
