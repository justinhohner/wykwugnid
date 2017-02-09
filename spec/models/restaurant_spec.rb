require 'rails_helper'

RSpec.describe Restaurant, type: :model do
  let(:restaurant) { FactoryGirl.build :restaurant }
  subject {  restaurant }

  it { is_expected.to respond_to(:title) }

  it { is_expected.to have_many(:restaurant_join_menus) }
  it { is_expected.to have_many(:menus).through(:restaurant_join_menus) }
  it { is_expected.to have_many(:restaurant_join_menu_items) }
  it { is_expected.to have_many(:menu_items).through(:restaurant_join_menu_items) }
  it { is_expected.to have_many(:restaurant_locations) }

  before(:each) do
    @restaurant1 = FactoryGirl.create :restaurant, { title: "Pi Pizza" }    
    @restaurant2 = FactoryGirl.create :restaurant, { title: "Panera" } 
    @restaurant3 = FactoryGirl.create :restaurant, { title: "Bettys Apple Pie Shop" }    
    @restaurant4 = FactoryGirl.create :restaurant, { title: "Toms Pies" }  
    @restaurant_location1 = FactoryGirl.create :restaurant_location, {
                                                restaurant_id: @restaurant1.id,
                                                formatted_address: 'Kemper Art Museum, 1 Brookings Dr, University City, MO 63130, USA',
                                                place_id: 'ChIJV3B3C7LK2IcRV1sxVtz3VA8',
                                                lat: 38.6470653,
                                                lng: -90.3026346
                                                }
    @restaurant_location2 = FactoryGirl.create :restaurant_location, {
                                                restaurant_id: @restaurant1.id,
                                                formatted_address: '600 Washington Ave, St. Louis, MO 63101, USA',
                                                place_id: 'ChIJzTyADh-z2IcRbUdndbVKOd4',
                                                lat: 38.6296495,
                                                lng: -90.1898815
                                                }
    @restaurant_location3 = FactoryGirl.create :restaurant_location, {
                                                restaurant_id: @restaurant2.id,
                                                formatted_address: '1010 St Charles St, St. Louis, MO 63101, USA',
                                                place_id: 'ChIJ_y-iXRiz2IcRpxS2lwEBShs',
                                                lat: 38.6304469,
                                                lng: -90.194412
                                                }
    @restaurant_location4 = FactoryGirl.create :restaurant_location, {
                                                restaurant_id: @restaurant2.id,
                                                formatted_address: '1122 Washington Ave, St. Louis, MO 63101, USA',
                                                place_id: 'ChIJ8QXoBBiz2IcRZoz5NFgwPos',
                                                lat: 38.6312705,
                                                lng: -90.1959367
                                                }       
    @restaurant_location5 = FactoryGirl.create :restaurant_location, {
                                                restaurant_id: @restaurant3.id,
                                                lat: 30.6312705,
                                                lng: -80.1959367
                                                }     
    @my_location  = FactoryGirl.create :location, {
                                                lat: 38.6304468,
                                                lng: -90.1944125
                                                }
    @menu_item1 = FactoryGirl.create :menu_item
    @menu_item2 = FactoryGirl.create :menu_item
    FactoryGirl.create :restaurant_join_menu_item, { restaurant_id: @restaurant1.id, menu_item_id: @menu_item1.id }
    FactoryGirl.create :restaurant_join_menu_item, { restaurant_id: @restaurant1.id, menu_item_id: @menu_item2.id }
  end

  describe "filter: " do
    context ".filter_by_title when a 'Pie' title pattern is sent" do
      it "returns the 2 foods matching" do
        expect(Restaurant.filter_by_title('Pie').size).to eq(2)
      end

      it "returns the foods matching" do
        expect(Restaurant.filter_by_title("Pie").sort).to match_array([@restaurant3, @restaurant4])
      end
    end
    
    it ".filter_by_max_distance" do
      # response = Restaurant.search({max_distance: 0.01, lat: @my_location.lat, lng: @my_location.lng })
      # expect(response.size).to eq(1)
      # response = Restaurant.search({max_distance: 0.5, lat: @my_location.lat, lng: @my_location.lng })
      # expect(response.size).to eq(2)
      # response = Restaurant.search({max_distance: 10, lat: @my_location.lat, lng: @my_location.lng })
      # expect(response.size).to eq(2)
      # response = Restaurant.search({max_distance: 1000000, lat: @my_location.lat, lng: @my_location.lng })
      # expect(response.size).to eq(3)
    end

  end

  describe "sort: " do
    context "by title alphabetically" do
      it "returns the 2 foods matching" do
        expect(Restaurant.order(:title)).to match_array([@restaurant3, @restaurant2, @restaurant1, @restaurant4])
      end
    end
    context "by distance" do
      it " of nearest locations" do
        # expect(Restaurant.all.sort_by { |r| r.restaurant_locations.empty? ? 9999 : r.nearest_location(@my_location)[1] }).to match_array([@restaurant2, @restaurant1,@restaurant3, @restaurant4])
      end
    end
  end

end
