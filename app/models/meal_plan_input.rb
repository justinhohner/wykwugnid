class MealPlanInput < ApplicationRecord
    has_many :sources_by_meals
    has_many :foods_by_sources, through: :sources_by_meal
    has_one :daily_constraint_set
    has_many :meal_constraint_sets, through: :daily_constraint_set
end
