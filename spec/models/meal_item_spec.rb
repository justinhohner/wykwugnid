require 'rails_helper'

RSpec.describe MealItem, type: :model do
  let(:meal_item) { FactoryGirl.build :meal_item }
  subject {  meal_item }

  it { is_expected.to respond_to(:amount) }
  it { is_expected.to respond_to(:meal_id) }
  it { is_expected.to respond_to(:food_id) }
end
