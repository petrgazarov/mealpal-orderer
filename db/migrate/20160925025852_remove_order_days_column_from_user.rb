class RemoveOrderDaysColumnFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :order_days
  end
end
