class AddUsedAtToMealPlans < ActiveRecord::Migration[5.0]
  def change
    add_column :meal_plans, :used_at, :date
  end
end
