require 'rails_helper'

RSpec.describe API::V1::PantryController, type: :controller do
  describe "POST #show" do
    before(:each) do
        current_user = FactoryGirl.create :user
        api_authorization_header current_user.auth_token
        FactoryGirl.create :pantry, user: current_user
        post :show, params: { user_id: current_user.id } 
    end

    it "returns 1 pantry record from the user" do
        pantry_response = json_response
        expect(pantry_response.size).to eq(1)
    end

    it { is_expected.to respond_with 200 }
  end

  describe "PUT/PATCH #update" do
    context "when pantry items are successfully updated" do
      before(:each) do
        @user = FactoryGirl.create :user
        @pantry = FactoryGirl.create :pantry, user: @user
        @food = FactoryGirl.create :food
        @pantry_item = FactoryGirl.create :pantry_item, { pantry_id: @pantry.id, food_id: @food.id }
        api_authorization_header @user.auth_token
        patch :update, params: { user_id: @user.id, #id: @pantry.id,
              pantry: { pantry_items: [{id: @pantry_item.id, amount: 50, food_id: @food.id}] } }
      end

      it "renders the json representation for the updated pantry item" do
        pantry_response = json_response[:pantry][:pantry_items][0][:amount]
        expect(pantry_response.to_i).to eql 50
      end

      it { is_expected.to respond_with 200 }
    end
  end

  describe "POST #add_food" do
    context "when pantry items are successfully updated" do
      before(:each) do
        @user = FactoryGirl.create :user
        @pantry = FactoryGirl.create :pantry, user: @user
        @food = FactoryGirl.create :food
        api_authorization_header @user.auth_token
        patch :add_food, params: { user_id: @user.id, pantry: {amount: 2, food: {id: @food.id}} }
      end

      it "renders the json representation for the updated pantry item" do
        pantry_response = json_response[:pantry][:pantry_items]
        expect(pantry_response.size).to eql 1
      end

      it { is_expected.to respond_with 200 }
    end
  end
end
