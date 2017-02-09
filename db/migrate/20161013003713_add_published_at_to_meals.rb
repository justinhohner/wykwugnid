class AddPublishedAtToMeals < ActiveRecord::Migration[5.0]
  def change
    add_column :meals, :published_at, :datetime
  end
end
