FactoryGirl.define do
  factory :recipe do
    title { FFaker::Product.product_name }
    published_at nil
    # calories { rand() * 100 }
    # fat { rand() * 100 }
    # carbohydrates { rand() * 100 }
    # protein { rand() * 100 }
    type "Recipe"
    user
  end
end