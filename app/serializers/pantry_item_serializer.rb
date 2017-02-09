class PantryItemSerializer < ActiveModel::Serializer
  attributes :id, :amount, :food_id, :food, :pantry_id
end
