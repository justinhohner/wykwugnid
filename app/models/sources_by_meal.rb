class SourcesByMeal < ApplicationRecord
  belongs_to :meal_plan_input
  has_many :foods_by_sources
end
