class OrderDay < ActiveRecord::Base
  after_initialize :ensure_scheduled_to_order

  validate :whitelist_is_array
  validate :blacklist_is_array
  validates :week_day_number, presence: true
  validates_uniqueness_of :week_day_number, :scope => :user_id

  belongs_to :user

  def whitelist
    super.join ', '
  end

  def blacklist
    super.join ', '
  end

  def whitelist=(value)
    super(value.split(/, |,/))
  end

  def blacklist=(value)
    super(value.split(/, |,/))
  end

  def week_day_word
    {
      1 => 'Monday',
      2 => 'Tuesday',
      3 => 'Wednesday',
      4 => 'Thursday',
      5 => 'Friday'
    }[week_day_number]
  end

  def user_profile_display_css
    scheduled_to_order? ? 'background-color: #90EE90;' : 'background-color: #C0C0C0;'
  end

  private

  def whitelist_is_array
    whitelist.blank? || whitelist.is_a?(Array)
  end

  def blacklist_is_array
    blacklist.blank? || blacklist.is_a?(Array)
  end

  def ensure_scheduled_to_order
    return unless scheduled_to_order == nil

    scheduled_to_order = true
  end
end
