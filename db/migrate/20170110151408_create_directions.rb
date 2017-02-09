class CreateDirections < ActiveRecord::Migration[5.0]
  def change
    create_table :directions do |t|
      t.text :step
      t.integer :recipe_id
      t.integer :position

      t.timestamps
    end
  end
end
