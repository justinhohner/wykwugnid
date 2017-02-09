class CreateSourcesByMeals < ActiveRecord::Migration[5.0]
  def change
    create_table :sources_by_meals do |t|
      t.references :meal_plan_input, foreign_key: true
      t.integer :position

      t.timestamps
    end
  end
end
