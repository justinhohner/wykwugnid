require 'rails_helper'

RSpec.describe Location, type: :model do
  let(:location) { FactoryGirl.build :location }
  subject {  location }

  it { is_expected.to respond_to(:lat) }
  it { is_expected.to respond_to(:lng) }
  it { is_expected.to respond_to(:formatted_address) }
  it { is_expected.to respond_to(:place_id) }
  
  before(:each) do
    @location1 = FactoryGirl.create :location, {
                                                formatted_address: 'Kemper Art Museum, 1 Brookings Dr, University City, MO 63130, USA',
                                                place_id: 'ChIJV3B3C7LK2IcRV1sxVtz3VA8',
                                                lat: 38.6470653,
                                                lng: -90.3026346
                                                }
    @location2 = FactoryGirl.create :location, {
                                                formatted_address: '600 Washington Ave, St. Louis, MO 63101, USA',
                                                place_id: 'ChIJzTyADh-z2IcRbUdndbVKOd4',
                                                lat: 38.6296495,
                                                lng: -90.1898815
                                                }
    @location3 = FactoryGirl.create :location, {
                                                formatted_address: '1010 St Charles St, St. Louis, MO 63101, USA',
                                                place_id: 'ChIJ_y-iXRiz2IcRpxS2lwEBShs',
                                                lat: 38.6304469,
                                                lng: -90.194412
                                                }
    @location4 = FactoryGirl.create :location, {
                                                formatted_address: '1122 Washington Ave, St. Louis, MO 63101, USA',
                                                place_id: 'ChIJ8QXoBBiz2IcRZoz5NFgwPos',
                                                lat: 38.6312705,
                                                lng: -90.1959367
                                                }
  end

  describe "calculate distance between two points" do
    it ' returns the correct distance' do
      expect((@location1.getDistance(@location2.lat, @location2.lng) - 6.22).abs).to be < 0.05
    end
  end

  describe "geocoding" do
    it 'geocodes lat,lng to correct formatted address' do
      response = @location1.geocode
      expect((response["lat"] - @location1.lat).abs).to be < 0.0000001
      expect(( response["lng"] - @location1.lng).abs).to be < 0.0000001
    end
    it 'reverse geocodes formatted address to correct lat,lng' do
      response = @location1.reverseGeocode
      expect(response).to eq(@location1.formatted_address)
    end
  end

  describe "filters: " do
    it 'finds the nearest location from an array of locations' do
      response = @location2.nearest_location([@location1,@location3,@location4])
      dist_to_location3 = @location2.getDistance(@location3.lat, @location3.lng)
      expect(response).to eq([@location3, dist_to_location3])
    end

    it 'filters the locations resuls by a max distance' do
      params = {max_distance: 1, lat: @location2.lat, lng: @location2.lng}
      response = Location.search(params)
      expect(response.size).to eq(3)
    end
  end

end
