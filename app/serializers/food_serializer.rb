class FoodSerializer < ActiveModel::Serializer
  cache key: 'food', expires_in: 30.minutes
  attributes :id, :title, :calories, :fat, :carbohydrates, :protein
end
