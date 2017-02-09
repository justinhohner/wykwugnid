class ConstraintSetSerializer < ActiveModel::Serializer
  attributes :id, :title, :user_id, :primary, :used_at,
    :min_calories, :target_calories, :max_calories,
    :min_fat, :target_fat, :max_fat,
    :min_carbohydrates, :target_carbohydrates, :max_carbohydrates,
    :min_protein, :target_protein, :max_protein
end