class PantryItem < ApplicationRecord
  belongs_to :pantry, inverse_of: :pantry_items
  belongs_to :food, inverse_of: :pantry_items
end
