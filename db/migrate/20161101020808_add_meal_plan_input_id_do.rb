class AddMealPlanInputIdDo < ActiveRecord::Migration[5.0]
  def change
    add_column :constraint_sets, :meal_plan_input_id, :integer
  end
end
