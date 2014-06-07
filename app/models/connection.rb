class Connection < ActiveRecord::Base
  # validates :source, :user_id, presence: true
  belongs_to :user
end