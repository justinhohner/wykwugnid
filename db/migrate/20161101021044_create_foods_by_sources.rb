class CreateFoodsBySources < ActiveRecord::Migration[5.0]
  def change
    create_table :foods_by_sources do |t|
      t.references :sources_by_meal, foreign_key: true
      t.integer :source_id
      t.boolean :all

      t.timestamps
    end
  end
end
