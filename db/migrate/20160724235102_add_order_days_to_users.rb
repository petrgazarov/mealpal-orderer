class AddOrderDaysToUsers < ActiveRecord::Migration
  def change
    add_column :users, :order_days, :text, array: true, default: []
  end
end
