class MenuJoinMenuItem < ApplicationRecord
  belongs_to :menu, inverse_of: :menu_join_menu_items
  belongs_to :menu_item, inverse_of: :menu_join_menu_items
end
