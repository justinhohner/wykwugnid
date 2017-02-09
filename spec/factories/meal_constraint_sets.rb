FactoryGirl.define do
  factory :meal_constraint_set do
    position 1
    min_calories 120
    target_calories 160
    max_calories 200
    min_fat 2
    target_fat 5
    max_fat 10
    min_carbohydrates 8
    target_carbohydrates 20
    max_carbohydrates 40
    min_protein 4
    target_protein 10
    max_protein 20
    user
    daily_constraint_set
  end

  factory :meal_constraint_set_breakfast, class: MealConstraintSet do
    position 1
    title 'Breakfast'
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
    user
    daily_constraint_set
  end

  factory :meal_constraint_set_lunch, class: MealConstraintSet do
    position 2
    title 'Lunch'
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
    user
    daily_constraint_set
  end

  factory :meal_constraint_set_dinner, class: MealConstraintSet do
    position 3
    title 'Dinner'
    min_calories 815 * 4/3
    target_calories 1144 * 4/3
    max_calories 1503 * 4/3
    min_fat 18 * 4/3
    target_fat 38 * 4/3
    max_fat 56 * 4/3
    min_carbohydrates 96 * 4/3
    target_carbohydrates 157 * 4/3
    max_carbohydrates 233 * 4/3
    min_protein 21 * 4/3
    target_protein 42 * 4/3
    max_protein 72 * 4/3
    user
    daily_constraint_set
  end

  factory :five_meals_constraint_set, class: MealConstraintSet do
    position 1
    title 'Meal Title'
    min_calories 3625 / 5
    target_calories 3816 / 5
    max_calories 4007 / 5
    min_fat 84 / 5
    target_fat 127 / 5
    max_fat 149 / 5
    min_carbohydrates 429 / 5
    target_carbohydrates 524 / 5
    max_carbohydrates 621 / 5
    min_protein 95 / 5
    target_protein 143 / 5
    max_protein 191 / 5
    user
    daily_constraint_set
  end
end