require 'rails_helper'

RSpec.describe RestaurantLocation, type: :model do
  let(:restaurant_location) { FactoryGirl.build :restaurant_location }
  subject {  restaurant_location }

  it { is_expected.to respond_to(:lat) }
  it { is_expected.to respond_to(:lng) }
  it { is_expected.to respond_to(:formatted_address) }
  it { is_expected.to respond_to(:place_id) }

  it { is_expected.to belong_to(:restaurant) }

  
  
  before(:each) do
    @restaurant_location1 = FactoryGirl.create :restaurant_location, {
                                                formatted_address: 'Kemper Art Museum, 1 Brookings Dr, University City, MO 63130, USA',
                                                place_id: 'ChIJV3B3C7LK2IcRV1sxVtz3VA8',
                                                lat: 38.6470653,
                                                lng: -90.3026346
                                                }
    @restaurant_location2 = FactoryGirl.create :restaurant_location, {
                                                formatted_address: '600 Washington Ave, St. Louis, MO 63101, USA',
                                                place_id: 'ChIJzTyADh-z2IcRbUdndbVKOd4',
                                                lat: 38.6296495,
                                                lng: -90.1898815
                                                }
    @restaurant_location3 = FactoryGirl.create :restaurant_location, {
                                                formatted_address: '1010 St Charles St, St. Louis, MO 63101, USA',
                                                place_id: 'ChIJ_y-iXRiz2IcRpxS2lwEBShs',
                                                lat: 38.6304469,
                                                lng: -90.194412
                                                }
    @restaurant_location4 = FactoryGirl.create :restaurant_location, {
                                                formatted_address: '1122 Washington Ave, St. Louis, MO 63101, USA',
                                                place_id: 'ChIJ8QXoBBiz2IcRZoz5NFgwPos',
                                                lat: 38.6312705,
                                                lng: -90.1959367
                                                }
  end

  describe "calculate distance between two points" do
    it ' returns the correct distance' do
      expect((@restaurant_location1.getDistance(@restaurant_location2.lat, @restaurant_location2.lng) - 6.22).abs).to be < 0.05
    end
  end

  describe "geocoding" do
    it 'geocodes lat,lng to correct formatted address' do
      response = @restaurant_location1.geocode
      expect((response["lat"] - @restaurant_location1.lat).abs).to be < 0.0000001
      expect(( response["lng"] - @restaurant_location1.lng).abs).to be < 0.0000001
    end
    it 'reverse geocodes formatted address to correct lat,lng' do
      response = @restaurant_location1.reverseGeocode
      expect(response).to eq(@restaurant_location1.formatted_address)
    end
  end

  describe "filters: " do
    it 'finds the nearest restaurant_location from an array of restaurant_locations' do
      response = @restaurant_location2.nearest_location([@restaurant_location1,@restaurant_location3,@restaurant_location4])
      dist_to_restaurant_location3 = @restaurant_location2.getDistance(@restaurant_location3.lat, @restaurant_location3.lng)
      expect(response).to eq([@restaurant_location3, dist_to_restaurant_location3])
    end

    it 'filters the restaurant_locations resuls by a max distance' do
      params = {max_distance: 1, lat: @restaurant_location2.lat, lng: @restaurant_location2.lng}
      response = Location.search(params)
      expect(response.size).to eq(3)
    end
  end
end
