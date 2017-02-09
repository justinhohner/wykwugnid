class Pantry < ApplicationRecord
  belongs_to :user
  validates :user_id, presence: true

  has_many :foods, through: :pantry_items
  has_many :pantry_items, dependent: :destroy
end
