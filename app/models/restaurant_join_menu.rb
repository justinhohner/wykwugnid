class RestaurantJoinMenu < ApplicationRecord
belongs_to :restaurant, inverse_of: :restaurant_join_menus
belongs_to :menu, inverse_of: :restaurant_join_menu
end
