class AddLastOrderedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_ordered_at, :datetime
  end
end
