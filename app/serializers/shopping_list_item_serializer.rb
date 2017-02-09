class ShoppingListItemSerializer < ActiveModel::Serializer
  attributes :id, :amount, :food_id, :food, :shopping_list_id
end
