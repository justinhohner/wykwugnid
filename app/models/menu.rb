class Menu < Source
  has_many :menu_join_menu_items
  has_many :menu_items, through: :menu_join_menu_items
  has_one :restaurant_join_menu
  has_one :restaurant, through: :restaurant_join_menu
end