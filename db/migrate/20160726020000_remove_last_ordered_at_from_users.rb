class RemoveLastOrderedAtFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :last_ordered_at
  end
end
