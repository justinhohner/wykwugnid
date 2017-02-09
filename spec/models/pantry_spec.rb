require 'rails_helper'

RSpec.describe Pantry, type: :model do
  let(:pantry) { FactoryGirl.build :pantry }
  subject { pantry }

  it { is_expected.to respond_to(:user_id) }

  it { is_expected.to validate_presence_of :user_id }

  it { is_expected.to belong_to :user }

  it { is_expected.to have_many(:pantry_items) }
  it { is_expected.to have_many(:foods).through(:pantry_items) }
end
