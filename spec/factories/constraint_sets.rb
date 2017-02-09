FactoryGirl.define do
  factory :constraint_set do
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
  end
end