class RestaurantJoinMenuItem < ApplicationRecord
  belongs_to :restaurant, inverse_of: :restaurant_join_menu_items
  belongs_to :menu_item, inverse_of: :restaurant_join_menu_item
end
