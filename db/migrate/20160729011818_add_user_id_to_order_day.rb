class AddUserIdToOrderDay < ActiveRecord::Migration
  def change
    add_column :order_days, :user_id, :integer
    add_foreign_key :order_days, :users
  end
end
