class ChangeCaloriesColumnMeals < ActiveRecord::Migration[5.0]
  def change
    change_column :meals, :calories, :decimal 
  end
end
