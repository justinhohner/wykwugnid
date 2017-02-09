require 'rails_helper'

RSpec.describe API::V1::MenuItemsController, type: :controller do
  describe "GET #index" do
    before(:each) do
      @menu_item1 = FactoryGirl.create :menu_item
      @menu_item2 = FactoryGirl.create :menu_item
      @menu_item3 = FactoryGirl.create :menu_item
      @menu_item4 = FactoryGirl.create :menu_item
      @restaurant1 = FactoryGirl.create :restaurant
      @restaurant2 = FactoryGirl.create :restaurant
      @rjmi1 = FactoryGirl.create :restaurant_join_menu_item, {restaurant_id: @restaurant1.id, menu_item_id: @menu_item1.id }
      @rjmi2 = FactoryGirl.create :restaurant_join_menu_item, {restaurant_id: @restaurant1.id, menu_item_id: @menu_item2.id }
      @rjmi3 = FactoryGirl.create :restaurant_join_menu_item, {restaurant_id: @restaurant1.id, menu_item_id: @menu_item3.id }
      @rjmi4 = FactoryGirl.create :restaurant_join_menu_item, {restaurant_id: @restaurant2.id, menu_item_id: @menu_item4.id }
    end
    context "when is not receiving any menu_items_ids parameter" do
      before(:each) do
        get :index
      end

      it "returns 4 records from the database" do
        menu_items_response = json_response[:menu_items]
        expect(menu_items_response.size).to eq(4)
      end

      it_behaves_like "paginated list"

      it { is_expected.to respond_with 200 }

    end

    context "when receiving restaurant_id parameter" do
      before(:each) do
        get :index, params: {restaurant_ids: [@restaurant1.id]}
      end

      it "returns 4 records from the database" do
        menu_items_response = json_response[:menu_items]
        expect(menu_items_response.size).to eq(3)
      end

      it { is_expected.to respond_with 200 }

    end

  end

  describe "GET #show" do
    before(:each) do
      @menu_item = FactoryGirl.create :menu_item
      @restaurant = FactoryGirl.create :restaurant
      @rjmi = FactoryGirl.create :restaurant_join_menu_item, {restaurant_id: @restaurant.id, menu_item_id: @menu_item.id }
      get :show, params: { id: @menu_item.id }
    end

    it "returns the information about a reporter on a hash" do
      menu_item_response = json_response[:menu_item]
      expect(menu_item_response[:title]).to eql @menu_item.title
    end

    it { is_expected.to respond_with 200 }
  end

end
