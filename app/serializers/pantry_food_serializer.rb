class PantryFoodSerializer < FoodSerializer
  def include_user?
    false
  end
end
