require 'rails_helper'

RSpec.describe API::V1::RestaurantsController, type: :controller do
  
  describe "GET #index" do
    before(:each) do
      4.times { FactoryGirl.create :restaurant }
    end
    context "when is not receiving any product_ids parameter" do
      before(:each) do
        get :index
      end

      it "returns 4 records from the database" do
        restaurants_response = json_response[:restaurants]  
        expect(restaurants_response.size).to eq(4)
      end

      it_behaves_like "paginated list"

      it { is_expected.to respond_with 200 }

    end

  end

  describe "GET #show" do
    before(:each) do
      @restaurant = FactoryGirl.create :restaurant
      get :show, params: { id: @restaurant.id }
    end

    it "returns the information about a reporter on a hash" do
      restaurant_response = json_response[:restaurant]
      expect(restaurant_response[:title]).to eql @restaurant.title
    end

    it { is_expected.to respond_with 200 }
  end

end
