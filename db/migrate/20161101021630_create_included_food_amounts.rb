class CreateIncludedFoodAmounts < ActiveRecord::Migration[5.0]
  def change
    create_table :included_food_amounts do |t|
      t.integer :food_id
      t.references :foods_by_source, foreign_key: true
      t.decimal :amount

      t.timestamps
    end
  end
end
