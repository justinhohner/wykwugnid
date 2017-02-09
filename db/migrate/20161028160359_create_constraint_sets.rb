class CreateConstraintSets < ActiveRecord::Migration[5.0]
  def change
    create_table :constraint_sets do |t|
      t.string :title
      t.references :user, foreign_key: true
      t.integer :min_calories, default: 0
      t.integer :target_calories, default: 0
      t.integer :max_calories, default: 999999
      t.decimal :min_fat, default: 0
      t.decimal :target_fat, default: 0
      t.decimal :max_fat, default: 999999
      t.decimal :min_carbohydrates, default: 0
      t.decimal :target_carbohydrates, default: 0
      t.decimal :max_carbohydrates, default: 999999
      t.decimal :min_protein, default: 0
      t.decimal :target_protein, default: 0
      t.decimal :max_protein, default: 999999
      t.integer :daily_constraint_set_id
      t.integer :position
      t.string  :type

      t.timestamps
    end
  end
end
