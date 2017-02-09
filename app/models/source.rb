class Source < ApplicationRecord
  has_many :source_items, dependent: :destroy
  has_many :foods, through: :source_items
  has_many :user_join_sources, dependent: :destroy
  has_many :users, through: :user_join_sources
end
