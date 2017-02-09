require 'rails_helper'

RSpec.describe MealConstraintSet, type: :model do
  let(:meal_constraint_set) { FactoryGirl.build :meal_constraint_set }
  subject {  meal_constraint_set }

  it { is_expected.to respond_to(:title) }
  it { is_expected.to respond_to(:user_id) }

  it { is_expected.to respond_to(:min_calories) }
  it { is_expected.to respond_to(:min_fat) }
  it { is_expected.to respond_to(:min_carbohydrates) }
  it { is_expected.to respond_to(:min_protein) }
  it { is_expected.to respond_to(:target_calories) }
  it { is_expected.to respond_to(:target_fat) }
  it { is_expected.to respond_to(:target_carbohydrates) }
  it { is_expected.to respond_to(:target_protein) }
  it { is_expected.to respond_to(:max_calories) }
  it { is_expected.to respond_to(:max_fat) }
  it { is_expected.to respond_to(:max_carbohydrates) }
  it { is_expected.to respond_to(:max_protein) }

  it { is_expected.to belong_to :user }
  it { is_expected.to belong_to :daily_constraint_set }

end