class ShoppingList < ApplicationRecord
  belongs_to :user
  validates :user_id, presence: true

  has_many :foods, through: :shopping_list_items
  has_many :shopping_list_items, dependent: :destroy
end
