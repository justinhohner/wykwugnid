FactoryGirl.define do
  factory :meal_plan do
    title { FFaker::Product.product_name }
    published_at nil
    # calories { rand() * 100 }
    # fat { rand() * 100 }
    # carbohydrates { rand() * 100 }
    # protein { rand() * 100 }
    user
  end
end
