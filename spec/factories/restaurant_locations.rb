FactoryGirl.define do
  factory :restaurant_location do
    street_number 1
    route "MyString"
    neighborhood "MyString"
    locality "MyString"
    administrative_area_level_1 "MyString"
    administrative_area_level_2 "MyString"
    administrative_area_level_3 "MyString"
    country "MyString"
    postal_code 1
    formatted_address "MyString"
    lat 9.99
    lng 9.99
    place_id "MyString"
    restaurant
  end
end
