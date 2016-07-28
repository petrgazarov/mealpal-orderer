class OrderDay < ActiveRecord::Base
  validates :week_day_number, presence: true

  belongs_to :user
end
