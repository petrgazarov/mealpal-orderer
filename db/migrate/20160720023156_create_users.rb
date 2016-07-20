class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :mealpass_email, null: false
      t.string :mealpass_password, null: false
      t.timestamps null: false
    end
  end
end
