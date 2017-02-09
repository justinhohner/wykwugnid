class CreateLocations < ActiveRecord::Migration[5.0]
  def change
    create_table :locations do |t|
      t.integer :street_number
      t.string :route
      t.string :neighborhood
      t.string :locality
      t.string :administrative_area_level_1
      t.string :administrative_area_level_2
      t.string :administrative_area_level_3
      t.string :country
      t.integer :postal_code
      t.string :formatted_address
      t.decimal :lat
      t.decimal :lng
      t.string :place_id

      t.timestamps
    end
  end
end
