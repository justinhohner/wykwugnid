class UserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :auth_token, #:created_at, :updated_at,  
              :age, :gender, :weight, :feet, :inches, :eer,
              :activity_level #:meal_plan_ids, :meal_ids, :recipe_ids,
  # has_many :meal_plans
  # has_many :meals
  # has_many :recipes
  # has_many :daily_constraint_sets
  # has_many :meal_constraint_sets

  private

  # def meal_plan_ids
  #   object.meal_plans.pluck(:id)
  # end
  
  # def meal_ids
  #   object.meals.pluck(:id)
  # end

  # def recipe_ids
  #   object.recipes.pluck(:id)
  # end

end
