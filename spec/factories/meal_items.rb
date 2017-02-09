FactoryGirl.define do
  factory :meal_item do
    meal
    food
    amount { rand() * 10 }
  end
end
