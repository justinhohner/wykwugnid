class CreateExcludedFoods < ActiveRecord::Migration[5.0]
  def change
    create_table :excluded_foods do |t|
      t.integer :food_id
      t.references :foods_by_source, foreign_key: true

      t.timestamps
    end
  end
end
