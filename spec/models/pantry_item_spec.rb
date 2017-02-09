require 'rails_helper'

RSpec.describe PantryItem, type: :model do
  let(:pantry_item) { FactoryGirl.build :pantry_item }
  subject { pantry_item }

  it { is_expected.to respond_to :pantry_id }
  it { is_expected.to respond_to :food_id }

  it { is_expected.to belong_to :pantry }
  it { is_expected.to belong_to :food }
end
