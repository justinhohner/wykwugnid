FactoryGirl.define do
  factory :daily_constraint_set do
    title 'My Daily Guidelines'
    min_calories 3625
    target_calories 3816
    max_calories 4007
    min_fat 84
    target_fat 127
    max_fat 149
    min_carbohydrates 429
    target_carbohydrates 524
    max_carbohydrates 621
    min_protein 95
    target_protein 143
    max_protein 191
    primary true
    user
  end

  factory :five_meals_daily_constraint_set, class: DailyConstraintSet do
    title 'My Daily Guidelines'
    min_calories 3625
    target_calories 3816
    max_calories 4007
    min_fat 84
    target_fat 127
    max_fat 149
    min_carbohydrates 429
    target_carbohydrates 524
    max_carbohydrates 621
    min_protein 95
    target_protein 143
    max_protein 191
    primary false
    user
  end

  factory :one_meal_daily_constraint_set, class: DailyConstraintSet do
    title 'My Daily Guidelines'
    min_calories 815
    target_calories 1144
    max_calories 1503
    min_fat 18
    target_fat 38
    max_fat 56
    min_carbohydrates 96
    target_carbohydrates 157
    max_carbohydrates 233
    min_protein 21
    target_protein 42
    max_protein 72
    primary false
    user
  end
end