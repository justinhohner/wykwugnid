require 'rails_helper'

RSpec.describe RestaurantJoinMenu, type: :model do
  let(:restaurant_join_menu) { FactoryGirl.build :restaurant_join_menu }
  subject { restaurant_join_menu }

  it { is_expected.to respond_to :menu_id }
  it { is_expected.to respond_to :restaurant_id }

  it { is_expected.to belong_to :menu }
  it { is_expected.to belong_to :restaurant }
end
