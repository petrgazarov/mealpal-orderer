class AddEarlyOrderToUser < ActiveRecord::Migration
  def change
    add_column :users, :early_order, :boolean, default: false
  end
end
