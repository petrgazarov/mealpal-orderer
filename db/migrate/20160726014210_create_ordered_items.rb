class CreateOrderedItems < ActiveRecord::Migration
  def change
    create_table :ordered_items do |t|

      t.string :name
      t.string :restaurant_name
      t.datetime :ordered_at
      t.timestamps null: false
    end
  end
end
