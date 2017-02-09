FactoryGirl.define do
  factory :ingredient do
    recipe
    food
    amount 2
  end
end
