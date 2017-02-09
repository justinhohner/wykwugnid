class MealSerializer < ActiveModel::Serializer
  attributes :id, :title, :user_id, :position, :meal_plan_id, :published_at, :used_at, :calories, :fat, :carbohydrates, :protein
  has_one :user # This embeds the user's auth_token for the meal. Is this a security concern?
  has_many :meal_items

end
