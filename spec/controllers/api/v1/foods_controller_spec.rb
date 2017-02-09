require 'rails_helper'

RSpec.describe API::V1::FoodsController, type: :controller do
  
  describe "GET #index" do
    before(:each) do
      4.times { FactoryGirl.create :food }
    end

    context "when is not receiving any food_ids parameter" do
      before(:each) do
        get :index
      end

      it "returns 4 records from the database" do
        foods_response = json_response[:foods]        
        expect(foods_response.size).to eq(4)
      end

      # we added these lines for the pagination
      it_behaves_like "paginated list"

      it { is_expected.to respond_with 200 }
    end

  end

  describe "GET #show" do
    before(:each) do
      @food = FactoryGirl.create :food
      get :show, params: { id: @food.id }
    end
    it "returns the information about a reporter on a hash" do
      food_response = json_response[:food]
      expect(food_response[:title]).to eql @food.title
    end
    it { is_expected.to respond_with 200 }
  end

end
