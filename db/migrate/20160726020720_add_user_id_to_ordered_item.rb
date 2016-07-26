class AddUserIdToOrderedItem < ActiveRecord::Migration
  def change
    add_column :ordered_items, :user_id, :integer
    add_foreign_key :ordered_items, :users
  end
end
