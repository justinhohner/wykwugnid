class MenuItemIngredientSerializer < ActiveModel::Serializer
  attributes :id, :food, :menu_item_id, :food_id
end
