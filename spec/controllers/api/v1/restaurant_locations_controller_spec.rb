require 'rails_helper'

RSpec.describe API::V1::RestaurantLocationsController, type: :controller do
  describe "GET #index" do

    context "when is not receiving any product_ids parameter: " do
      before(:each) do
        4.times { FactoryGirl.create :restaurant_location }
        get :index
      end

      it "returns 4 records from the database" do
        restaurant_locations_response = json_response[:restaurant_locations]
        expect(restaurant_locations_response.size).to eq(4)
      end

      it { is_expected.to respond_with 200 }
    end

    context "when given restaurants: " do
      before(:each) do
        @restaurant = FactoryGirl.create :restaurant
        @restaurant_location1 = FactoryGirl.create :restaurant_location, {
                                                    restaurant_id: @restaurant.id,
                                                    formatted_address: 'Kemper Art Museum, 1 Brookings Dr, University City, MO 63130, USA',
                                                    place_id: 'ChIJV3B3C7LK2IcRV1sxVtz3VA8',
                                                    lat: 38.6470653,
                                                    lng: -90.3026346
                                                    }
        @restaurant_location2 = FactoryGirl.create :restaurant_location, {
                                                    restaurant_id: @restaurant.id,
                                                    formatted_address: '600 Washington Ave, St. Louis, MO 63101, USA',
                                                    place_id: 'ChIJzTyADh-z2IcRbUdndbVKOd4',
                                                    lat: 38.6296495,
                                                    lng: -90.1898815
                                                    }
        @restaurant_location3 = FactoryGirl.create :restaurant_location, {
                                                    restaurant_id: @restaurant.id,
                                                    formatted_address: '1010 St Charles St, St. Louis, MO 63101, USA',
                                                    place_id: 'ChIJ_y-iXRiz2IcRpxS2lwEBShs',
                                                    lat: 38.6304469,
                                                    lng: -90.194412
                                                    }
        @restaurant_location4 = FactoryGirl.create :restaurant_location, {
                                                    restaurant_id: @restaurant.id,
                                                    formatted_address: '1122 Washington Ave, St. Louis, MO 63101, USA',
                                                    place_id: 'ChIJ8QXoBBiz2IcRZoz5NFgwPos',
                                                    lat: 38.6312705,
                                                    lng: -90.1959367
                                                    }
      end
      context "when map bounds are given: " do
        before(:each) do
            get :index, params: {min_lat: 38.63, max_lat: 40, min_lng: -91, max_lng:  -90.195}
        end
        it "returns 4 records from the database" do
            restaurant_locations_response = json_response[:restaurant_locations]
            expect(restaurant_locations_response.size).to eq(2)
        end
      end
      context "when user location and max_distance are given: " do
        before(:each) do
            get :index, params: {max_distance: "1", lat: "38.62964", lng: "-90.189881"}
        end
        it "returns  records from the database" do
            restaurant_locations_response = json_response[:restaurant_locations]
            expect(restaurant_locations_response.size).to eq(3)
        end
      end
    end
  end
end
