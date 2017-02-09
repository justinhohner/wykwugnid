require 'rails_helper'

RSpec.describe Menu, type: :model do
  let(:menu) { FactoryGirl.build :menu }
  subject {  menu }

  it { is_expected.to respond_to(:title) }


  it { is_expected.to have_many(:menu_join_menu_items) }
  it { is_expected.to have_many(:menu_items).through(:menu_join_menu_items) }
  it { is_expected.to have_one(:restaurant_join_menu) }
  it { is_expected.to have_one(:restaurant).through(:restaurant_join_menu) }

end
