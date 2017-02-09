class MenuItemIngredient < ApplicationRecord
  belongs_to :food, inverse_of: :menu_item_ingredients
  belongs_to :menu_item, inverse_of: :menu_item_ingredients
end
