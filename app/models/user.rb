class User < ActiveRecord::Base
  validates :mealpass_email, :mealpass_password, presence: true

  validates_uniqueness_of :mealpass_email, :mealpass_password
end
