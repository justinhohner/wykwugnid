class PantrySerializer < ActiveModel::Serializer
  attributes :id
  has_many :pantry_items #, serializer: PantryFoodSerializer
end
