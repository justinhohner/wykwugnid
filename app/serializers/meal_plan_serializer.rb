class MealPlanSerializer < ActiveModel::Serializer
  attributes :id, :title, :published_at, :used_at, :calories, :fat, :carbohydrates, :protein, :user_id
  #has_one :user # This embeds the user's auth_token for the meal. Is this a security concern?
  has_many :meals

end
