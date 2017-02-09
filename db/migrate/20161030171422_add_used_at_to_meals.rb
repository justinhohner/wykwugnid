class AddUsedAtToMeals < ActiveRecord::Migration[5.0]
  def change
    add_column :meals, :used_at, :date
  end
end
