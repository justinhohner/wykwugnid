class ShoppingListItem < ApplicationRecord
  belongs_to :shopping_list, inverse_of: :shopping_list_items
  belongs_to :food, inverse_of: :shopping_list_items
end
