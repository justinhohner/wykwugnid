class IngredientSerializer < ActiveModel::Serializer
  attributes :id, :amount, :measure, :food_id, :food, :recipe_id # Added recipe_id w/o testing
end
