class User < ActiveRecord::Base
  after_initialize :create_order_days_for_user
  after_initialize :ensure_session_token

  validates :mealpal_email, :mealpal_password, :session_token, presence: true
  validates_uniqueness_of :mealpal_email
  validates_format_of :mealpal_email, :with => /@/

  has_many :ordered_items, dependent: :destroy
  has_many :order_days, dependent: :destroy
  has_many :events, dependent: :destroy

  accepts_nested_attributes_for :order_days

  def create_order_days_for_user
    return unless order_days.blank?

    1.upto(5) do |day_number|
      order_days.build(week_day_number: day_number)
    end
  end

  def self.find_by_credentials(mealpal_email, mealpal_password)
    user = User.find_by(mealpal_email: mealpal_email)

    if user
      user.mealpal_password == mealpal_password ? user : nil
    else
      nil
    end
  end

  def reset_session_token!
    self.session_token = self.class.generate_session_token
    self.save!
  end

  def order_early?
    early_order
  end

  private

  def self.generate_session_token
    SecureRandom.urlsafe_base64
  end

  def ensure_session_token
    self.session_token ||= self.class.generate_session_token
  end
end
