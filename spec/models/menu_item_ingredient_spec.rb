require 'rails_helper'

RSpec.describe MenuItemIngredient, type: :model do
  let(:menu_item_ingredient) { FactoryGirl.build :menu_item_ingredient }
  subject { menu_item_ingredient }

  it { is_expected.to respond_to :menu_item_id }
  it { is_expected.to respond_to :food_id }

  it { is_expected.to belong_to :menu_item }
  it { is_expected.to belong_to :food }
end
