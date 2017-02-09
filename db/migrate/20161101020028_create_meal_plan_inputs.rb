class CreateMealPlanInputs < ActiveRecord::Migration[5.0]
  def change
    create_table :meal_plan_inputs do |t|

      t.timestamps
    end
  end
end
