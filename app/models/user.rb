class User < ActiveRecord::Base
  after_initialize :create_order_days_for_user

  validates :mealpass_email, :mealpass_password, presence: true
  validates_uniqueness_of :mealpass_email, :mealpass_password
  validates_format_of :mealpass_email, :with => /@/

  has_many :ordered_items, dependent: :destroy
  has_many :order_days, dependent: :destroy

  accepts_nested_attributes_for :order_days

  def create_order_days_for_user
    return unless order_days.blank?

    1.upto(5) do |day_number|
      order_days.build(week_day_number: day_number)
    end
  end
end
