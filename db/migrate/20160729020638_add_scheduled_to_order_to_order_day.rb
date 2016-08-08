class AddScheduledToOrderToOrderDay < ActiveRecord::Migration
  def change
    add_column :order_days, :scheduled_to_order, :boolean, default: true
  end
end
