require 'rails_helper'

RSpec.describe API::V1::MealsController, type: :controller do

  describe "GET #index" do
    before(:each) do
      4.times { FactoryGirl.create :meal}
    end
    context "when is not receiving any meal_ids parameter" do
      before(:each) do
        get :index
      end

      it "returns 4 records from the database" do
        meals_response = json_response[:meals]
        expect(meals_response.size).to eq(4)
      end

      it "returns the user object into each meal" do
        meals_response = json_response[:meals]
        meals_response.each do |meal_response|
          expect(meal_response[:user]).to be_present
        end
      end

      it { is_expected.to respond_with 200 }

    end

    context "when meal_ids parameter is sent" do
      before(:each) do
        @user = FactoryGirl.create :user
        3.times { FactoryGirl.create :meal, user: @user }
        get :index, params: { meal_ids: @user.meal_ids }
      end

      it "returns just the meals that belong to the user" do
        meals_response = json_response[:meals]
        meals_response.each do |meal_response|
          expect(meal_response[:user][:email]).to eql @user.email
        end
      end
    end

  end

  describe "GET #show" do
    before(:each) do
      @meal = FactoryGirl.create :meal
      get :show, params: { id: @meal.id }
    end

    it "returns the information about a reporter on a hash" do
      meal_response = json_response[:meal]
      expect(meal_response[:title]).to eql @meal.title
    end

    it "has the user as a embeded object" do
      meal_response = json_response[:meal]
      expect(meal_response[:user][:email]).to eql @meal.user.email
    end

    it { is_expected.to respond_with 200 }
  end

  describe "POST #create" do
    context "when is successfully created" do
      before(:each) do
        user = FactoryGirl.create :user
        meal_plan = FactoryGirl.create :meal_plan
        @meal_attributes = FactoryGirl.attributes_for :meal, meal_plan_id: meal_plan.id
        api_authorization_header user.auth_token
        post :create, params: { user_id: user.id, meal: @meal_attributes }
      end

      it "renders the json representation for the meal record just created" do
        meal_response = json_response[:meal]
        expect(meal_response[:title]).to eql @meal_attributes[:title]
      end

      it { is_expected.to respond_with 201 }
    end

    context "when is successfully created with meal_items" do
      before(:each) do
        user = FactoryGirl.create :user
        meal_plan = FactoryGirl.create :meal_plan
        @food_1 = FactoryGirl.create :food
        @food_2 = FactoryGirl.create :food
        @meal_attributes = { title: 'new title', meal_plan_id: meal_plan.id,
          meal_items: [
            {amount:2, food_id: @food_1.id},
            {amount:1, food_id: @food_2.id}
          ] }
        api_authorization_header user.auth_token
        post :create, params: { user_id: user.id, meal: @meal_attributes }
      end

      it "renders the json representation for the meal record just created" do
        meal_response = json_response[:meal]
        expect(meal_response[:title]).to eql @meal_attributes[:title]
      end

      it "renders the json of 2 meal_items records" do
        meal_response = json_response[:meal]
        expect(meal_response[:meal_items].size).to eq(2)
      end

      it { is_expected.to respond_with 201 }
    end

    # This should normally work to not specity a meal plan since the default is 1.
    # But, since this is the test database, the default meal_plan with id == 1 doesn't exist.
    # This tests defining an incorrect meal_plan.id
    context "when is not created" do
      before(:each) do
        user = FactoryGirl.create :user
        @invalid_meal_attributes = { title: "Smart TV" }
        api_authorization_header user.auth_token
        post :create, params: { user_id: user.id, meal: @invalid_meal_attributes }
      end

      it "renders an errors json" do
        meal_response = json_response
        expect(meal_response).to have_key(:errors)
      end

      it "renders the json errors on why the user could not be created" do
        meal_response = json_response
        expect(meal_response[:errors][:meal_plan]).to include "must exist"
      end

      it { is_expected.to respond_with 422 }
    end
  end

  describe "PUT/PATCH #update" do

    context "when is successfully updated" do
      before(:each) do
        @user = FactoryGirl.create :user
        @meal = FactoryGirl.create :meal, user: @user
        api_authorization_header @user.auth_token
        patch :update, params: { user_id: @user.id, id: @meal.id,
              meal: { title: "An expensive TV" } }
      end

      it "renders the json representation for the updated user" do
        meal_response = json_response[:meal]
        expect(meal_response[:title]).to eql "An expensive TV"
      end

      it { is_expected.to respond_with 200 }
    end

    context "when meal items are successfully updated" do
      before(:each) do
        @user = FactoryGirl.create :user
        @meal2 = FactoryGirl.create :meal, user: @user
        @food = FactoryGirl.create :food
        @meal_item = FactoryGirl.create :meal_item, { meal_id: @meal2.id, food_id: @food.id }
        api_authorization_header @user.auth_token
        patch :update, params: { user_id: @user.id, id: @meal2.id,
              meal: { meal_items: [{id: @meal_item.id, amount: 50, food_id: @food.id}] } }
      end

      it "renders the json representation for the updated meal item" do
        # Taking the first meal item, since there's only one.
        meal_response = json_response[:meal][:meal_items][0][:amount]
        expect(meal_response.to_i).to eql 50
      end

      it { is_expected.to respond_with 200 }
    end

  #   context "when is not updated" do
  #     before(:each) do
  #       @user = FactoryGirl.create :user
  #       @meal = FactoryGirl.create :meal, user: @user
  #       api_authorization_header @user.auth_token
  #       patch :update, params: { user_id: @user.id, id: @meal.id,
  #             meal: { title: "two hundred" } }
  #     end

  #     it "renders an errors json" do
  #       meal_response = json_response
  #       expect(meal_response).to have_key(:errors)
  #     end

  #     it "renders the json errors on whye the user could not be created" do
  #       meal_response = json_response
  #       expect(meal_response[:errors][:calories]).to include "is not a number"
  #     end

  #     it { is_expected.to respond_with 422 }
  #   end
  end

  describe "DELETE #destroy" do
    before(:each) do
      @user = FactoryGirl.create :user
      @meal = FactoryGirl.create :meal, user: @user
      api_authorization_header @user.auth_token
      delete :destroy, params: { user_id: @user.id, id: @meal.id }
    end

    it { is_expected.to respond_with 204 }
  end

end

