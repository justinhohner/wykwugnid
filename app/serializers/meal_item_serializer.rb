class MealItemSerializer < ActiveModel::Serializer
  attributes :id, :amount, :measure, :food, :meal_id, :food_id  # Added meal_id w/o testing
end
