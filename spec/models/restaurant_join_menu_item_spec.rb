require 'rails_helper'

RSpec.describe RestaurantJoinMenuItem, type: :model do
    let(:restaurant_join_menu_item) { FactoryGirl.build :restaurant_join_menu_item }
  subject { restaurant_join_menu_item }

  it { is_expected.to respond_to :menu_item_id }
  it { is_expected.to respond_to :restaurant_id }

  it { is_expected.to belong_to :menu_item }
  it { is_expected.to belong_to :restaurant }
end
