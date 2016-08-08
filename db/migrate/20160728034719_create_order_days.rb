class CreateOrderDays < ActiveRecord::Migration
  def change
    create_table :order_days do |t|
      t.integer :week_day_number, null: false
      t.text :whitelist, array: true, default: []
      t.text :blacklist, array: true, default: []
      t.string :pick_up_time, default: '12:00pm-12:15pm'
      t.timestamps null: false
    end
  end
end
