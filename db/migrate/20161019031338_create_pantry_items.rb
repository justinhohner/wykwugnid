class CreatePantryItems < ActiveRecord::Migration[5.0]
  def change
    create_table :pantry_items do |t|
      t.references :pantry, foreign_key: true
      t.references :food, foreign_key: true

      t.timestamps
    end
  end
end
