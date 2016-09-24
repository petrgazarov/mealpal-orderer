class RenameMealpassToMealpal < ActiveRecord::Migration
  def change
    rename_column :users, :mealpass_email, :mealpal_email
    rename_column :users, :mealpass_password, :mealpal_password
  end
end
