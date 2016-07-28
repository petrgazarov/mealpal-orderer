class User < ActiveRecord::Base
  validates :mealpass_email, :mealpass_password, presence: true
  validates_uniqueness_of :mealpass_email, :mealpass_password
  validates_format_of :mealpass_email, :with => /@/

  has_many :ordered_items
  has_many :order_days
  accepts_nested_attributes_for :order_days
end
