class Group < ActiveRecord::Base

  has_and_belongs_to_many :users

  validates_presence_of :name, :users
  validates :name, length: { maximum: 50 }
end
