class AddUniqueConstraintToUsersAndOrderDays < ActiveRecord::Migration
  def change
    add_index :order_days, [ :user_id, :week_day_number ], :unique => true
  end
end
