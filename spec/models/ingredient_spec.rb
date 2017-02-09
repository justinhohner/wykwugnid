require 'rails_helper'

RSpec.describe Ingredient, type: :model do
  let(:ingredient) { FactoryGirl.build :ingredient }
  subject { ingredient }

  it { is_expected.to respond_to :recipe_id }
  it { is_expected.to respond_to :food_id }
  it { is_expected.to respond_to :amount }

  it { is_expected.to belong_to :recipe }
  it { is_expected.to belong_to :food }
end
