class AddPublishedAtToFoods < ActiveRecord::Migration[5.0]
  def change
    add_column :foods, :published_at, :datetime
  end
end
