FactoryGirl.define do
  factory :food do
    title { FFaker::Product.product_name }
    calories { rand() * 100 }
    fat { rand() * 100 }
    carbohydrates { rand() * 100 }
    protein { rand() * 100 }
    type ""
  end
end