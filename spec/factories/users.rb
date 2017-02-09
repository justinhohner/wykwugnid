FactoryGirl.define do
  factory :user do
    email { FFaker::Internet.email }
    password "12345678"
    password_confirmation "12345678"
    age 25
    weight  150
    gender 'Male'
    feet 5
    inches  5
    eer 3000
  end
end
