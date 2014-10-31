class Content < ActiveRecord::Base
  belongs_to :group
  has_and_belongs_to_many :users

  validates_presence_of :group

  mount_uploader :image, ContentImageUploader
end
