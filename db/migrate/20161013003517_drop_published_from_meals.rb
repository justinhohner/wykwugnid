class DropPublishedFromMeals < ActiveRecord::Migration[5.0]
  def change
    remove_column :meals, :published
  end
end
