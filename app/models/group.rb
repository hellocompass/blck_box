class Group < ActiveRecord::Base

  has_and_belongs_to_many :users
  has_many :contents

  validates_presence_of :name, :users
  validates :name, length: { maximum: 50 }
  validate :ensure_enabled

  scope :enabled, lambda { where(enabled: true) }

  after_find :maybe_disable_group

  private

  def maybe_disable_group
    if enabled && created_at < 72.hours.ago
      self.enabled = false
      save!
    end
  end

  def ensure_enabled
    unless enabled || enabled_was
      errors.add :enabled, 'This blackIn has expired.'
    end
  end
end
