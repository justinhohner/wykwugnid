class ShoppingListSerializer < ActiveModel::Serializer
  attributes :id
  has_many :shopping_list_items
end
