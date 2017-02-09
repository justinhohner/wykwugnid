class FoodsBySource < ApplicationRecord
  belongs_to :sources_by_meal
  has_many :included_foods
  has_many :excluded_foods
  has_many :included_food_amounts
end
