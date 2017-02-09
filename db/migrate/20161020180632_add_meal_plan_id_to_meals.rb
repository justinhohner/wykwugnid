class AddMealPlanIdToMeals < ActiveRecord::Migration[5.0]
  def change
    add_column :meals, :meal_plan_id, :integer, default: 1
  end
end
