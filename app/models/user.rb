class User < ActiveRecord::Base
  validates :mealpass_email, :mealpass_password, presence: true
  validates_uniqueness_of :mealpass_email, :mealpass_password
  validates_format_of :mealpass_email, :with => /@/

  has_many :ordered_items
end
