class AdminMailer < ApplicationMailer
  def send_status_report_error(user)
    @user = user

    mail(
      to: ENV['ADMIN_EMAIL'],
      subject: 'Status report: error'
    )
  end

  def send_status_report_success(user)
    today = (TZInfo::Timezone.get('America/New_York').now.wday + 1)
    order_day = user.order_days.find { |od| od.week_day_number == today }

    @user = user
    @ordered_item = OpenStruct.new(
      name: user.ordered_items.last.name,
      ordered_at: user.ordered_items.last.created_at,
      restaurant_name: user.ordered_items.last.restaurant_name
    )
    @user_preferences = OpenStruct.new(
      whitelist: order_day.whitelist,
      blacklist: order_day.blacklist
    )

    mail(
      to: ENV['ADMIN_EMAIL'],
      subject: 'Status report: success'
    )
  end
end
