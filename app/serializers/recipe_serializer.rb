class RecipeSerializer < ActiveModel::Serializer
  cache key: 'recipe', expires_in: 30.minutes
  
  attributes :id, :title, :published_at, :user_id, :hr, :min, :calories, :fat, :carbohydrates, :protein
  #has_one :user # This embeds the user's auth_token for the meal. Is this a security concern?
  has_many :directions
  has_many :ingredients
end
