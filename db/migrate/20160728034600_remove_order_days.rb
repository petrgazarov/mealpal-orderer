class RemoveOrderDays < ActiveRecord::Migration
  def change
    drop_table :order_days
  end
end
