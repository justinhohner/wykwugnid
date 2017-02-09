require 'rails_helper'

RSpec.describe API::V1::MealPlansController, type: :controller do
  
  describe "GET #index" do
    before(:each) do
      4.times { FactoryGirl.create :meal_plan }
    end
    context "when is not receiving any meal_plan_ids parameter" do
      before(:each) do
        get :index
      end

      it "returns 4 records from the database" do
        meal_plans_response = json_response[:meal_plans]
        expect(meal_plans_response.size).to eq(4)
      end

      it "returns the user object into each meal_plan" do
        meal_plans_response = json_response[:meal_plans]
        meal_plans_response.each do |meal_plan_response|
          expect(meal_plan_response[:user_id]).to be_present
        end
      end

      it { is_expected.to respond_with 200 }

    end

    context "when meal_plan_ids parameter is sent" do
      before(:each) do
        @user = FactoryGirl.create :user
        3.times { FactoryGirl.create :meal_plan, user: @user }
        get :index, params: { meal_plan_ids: @user.meal_plan_ids }
      end

      it "returns just the meal_plans that belong to the user" do
        meal_plans_response = json_response[:meal_plans]
        meal_plans_response.each do |meal_plan_response|
          expect(meal_plan_response[:user_id]).to eql @user.id
        end
      end
    end

  end

  describe "GET #show" do
    before(:each) do
      @meal_plan = FactoryGirl.create :meal_plan
      get :show, params: { id: @meal_plan.id }
    end

    it "returns the information about a reporter on a hash" do
      meal_plan_response = json_response[:meal_plan]
      expect(meal_plan_response[:title]).to eql @meal_plan.title
    end

    # it "has the user as a embeded object" do
    #   meal_plan_response = json_response[:meal_plan]
    #   binding.pry
    #   expect(meal_plan_response[:user][:email]).to eql @meal_plan.user.email
    # end

    it { is_expected.to respond_with 200 }
  end

  describe "POST #create" do
    context "when is successfully created" do
      before(:each) do
        user = FactoryGirl.create :user
        @meal_plan_attributes = FactoryGirl.attributes_for :meal_plan
        api_authorization_header user.auth_token
        post :create, params: { user_id: user.id, meal_plan: @meal_plan_attributes }
      end

      it "renders the json representation for the meal record just created" do
        meal_plan_response = json_response[:meal_plan]
        expect(meal_plan_response[:title]).to eql @meal_plan_attributes[:title]
      end

      it { is_expected.to respond_with 201 }
    end

    context "when is successfully created with new meals (i.e. not from other meal plans) and no meal items in the meals" do
      before(:each) do
        user = FactoryGirl.create :user
        @meal_1 = FactoryGirl.create :meal
        @meal_1.id = nil
        @meal_2 = FactoryGirl.create :meal
        @meal_2.id = nil
        @meal_plan_attributes = { title: 'new title', meals: [@meal_1, @meal_2]}
        api_authorization_header user.auth_token
        post :create, params: { user_id: user.id, meal_plan: @meal_plan_attributes }
      end

      it "renders the json representation for the meal_plan record just created" do
        meal_plan_response = json_response[:meal_plan]
        expect(meal_plan_response[:title]).to eql @meal_plan_attributes[:title]
      end

      it "renders the json of 2 meals records" do
        meal_plan_response = json_response[:meal_plan][:meals]
        expect(meal_plan_response.size).to eq(2)
      end

      it { is_expected.to respond_with 201 }
    end

    context "when is successfully created with meals from other meal plans and no meal items in the meals" do
      before(:each) do
        user = FactoryGirl.create :user
        @meal_1 = FactoryGirl.create :meal
        @meal_2 = FactoryGirl.create :meal
        @meal_plan_attributes = { title: 'new title', meals: [@meal_1, @meal_2]}
        api_authorization_header user.auth_token
        post :create, params: { user_id: user.id, meal_plan: @meal_plan_attributes }
      end

      ###################################################################
      # it "renders the json representation for the meal_plan record just created" do
      #   meal_plan_response = json_response[:meal_plan]
      #   expect(meal_plan_response[:title]).to eql @meal_plan_attributes[:title]
      # end

      # it "renders the json of 2 meals records" do
      #   meal_plan_response = json_response[:meal_plan][:meals]
      #   expect(meal_plan_response.size).to eq(2)
      # end

      # it { is_expected.to respond_with 201 }
      ###################################################################
    end

    context "when is successfully created with meals from other meal plans and two meal items in each meals" do
      before(:each) do
        user = FactoryGirl.create :user
        @food_1 = FactoryGirl.create :food
        @food_2 = FactoryGirl.create :food
        @food_3 = FactoryGirl.create :food
        @food_4 = FactoryGirl.create :food
        @meal_1_attributes = { title: 'new title 1',
          meal_items: [
            {amount:2, food_id: @food_1.id},
            {amount:1, food_id: @food_2.id}
        ] }
        @meal_2_attributes = { title: 'new title 2',
          meal_items: [
            {amount:2, food_id: @food_3.id},
            {amount:3, food_id: @food_4.id}
        ] }
        @meal_plan_attributes = { title: 'new title', meals: [@meal_1_attributes, @meal_2_attributes]}
        api_authorization_header user.auth_token
        post :create, params: { user_id: user.id, meal_plan: @meal_plan_attributes }
      end

      it "renders the json representation for the meal_plan record just created" do
        meal_plan_response = json_response[:meal_plan]
        expect(meal_plan_response[:title]).to eql @meal_plan_attributes[:title]
      end

      it "renders the json of 2 meals records" do
        meal_plan_response = json_response[:meal_plan][:meals]
        expect(meal_plan_response.size).to eq(2)
      end

      it { is_expected.to respond_with 201 }
    end

    ###################################################################
    # context "when is not created" do
    #   before(:each) do
    #     user = FactoryGirl.create :user
    #     @invalid_meal_plan_attributes = { title: "Smart TV", calories: "Twelve Calories" }
    #     api_authorization_header user.auth_token
    #     post :create, params: { user_id: user.id, meal_plan: @invalid_meal_plan_attributes }
    #   end

    #   it "renders an errors json" do
    #     meal_plan_response = json_response
    #     expect(meal_plan_response).to have_key(:errors)
    #   end

    #   it "renders the json errors on why the user could not be created" do
    #     meal_plan_response = json_response
    #     expect(meal_plan_response[:errors][:calories]).to include "is not a number"
    #   end

    #   it { is_expected.to respond_with 422 }
    # end
    ###################################################################
  end

  describe "PUT/PATCH #update" do
    before(:each) do
      @user = FactoryGirl.create :user
      @meal_plan = FactoryGirl.create :meal_plan, user: @user
      api_authorization_header @user.auth_token
      @food_1 = FactoryGirl.create :food
      @food_2 = FactoryGirl.create :food
      @food_3 = FactoryGirl.create :food
      @food_4 = FactoryGirl.create :food
      @meal_1 = FactoryGirl.create :meal, {title: 'meal 1', user: @user, meal_plan_id: @meal_plan.id}
      @meal_2 = FactoryGirl.create :meal, {title: 'meal 2', user: @user, meal_plan_id: @meal_plan.id}
      @meal_item_1 = FactoryGirl.create :meal_item, { meal_id: @meal_1.id, amount:2, food_id: @food_1.id}
      @meal_item_2 = FactoryGirl.create :meal_item, {meal_id: @meal_1.id, amount:1, food_id: @food_2.id}
      @meal_item_3 = FactoryGirl.create :meal_item, {meal_id: @meal_2.id, amount:2, food_id: @food_3.id}
      @meal_item_4 = FactoryGirl.create :meal_item, {meal_id: @meal_2.id, amount:3, food_id: @food_4.id}
    end

    context "when title is successfully updated" do
      before(:each) do
        patch :update, params: { user_id: @user.id, id: @meal_plan.id,
              meal_plan: { title: "An expensive TV" } }
      end

      it "renders the json representation for the updated user" do
        meal_plan_response = json_response[:meal_plan]
        expect(meal_plan_response[:title]).to eql "An expensive TV"
      end

      it { is_expected.to respond_with 200 }
    end

    context "when successfully updating by adding a meal" do
      before(:each) do
        patch :update, params: { user_id: @user.id, id: @meal_plan.id,
              meal_plan: { meals: [ {
                title: 'meal 3', meal_items: [
                { amount:20, food_id: @food_2.id},
                { amount:10, food_id: @food_3.id}
                ]
              }
              ]} }
      end

      it "renders the json representation for the updated meal item" do
        # Taking the first meal item, since there's only one.
        meal_plan_response = json_response[:meal_plan][:meals]
        expect(meal_plan_response.size).to eq(3)
      end

      ####################################################################
      ### Meal Items are being saved corretly, but not returned in JSON ##
      # But you can't call another conroller from inside this controller #
      ####################################################################
      it "there should be two meal items in the new meal" do
        # Taking the first meal item, since there's only one.
        meal_item_response = json_response[:meal_plan][:meals][2][:meal_items]
        expect(meal_item_response.size).to eq(2)
      end

      it { is_expected.to respond_with 200 }
    end

    context "when successfully updating by adding meal item to a meal" do
      before(:each) do
        patch :update, params: { user_id: @user.id, id: @meal_plan.id,
              meal_plan: { meals: [{
                 id: @meal_1.id, meal_plan_id: @meal_plan.id, meal_items: [
                    { meal_id: @meal_1.id, amount: 100, food_id: @food_4.id } ]
                  }]
                } 
              }
      end

      it "renders the json representation for the updated meal item" do
        meal_item_response = json_response[:meal_plan][:meals][0][:meal_items]
        expect(meal_item_response.size).to eql(2)
      end

      it { is_expected.to respond_with 200 }
    end

    context "when successfully updating by changing the food in a meal item in a meal" do
      before(:each) do
        patch :update, params: { user_id: @user.id, id: @meal_plan.id,
              meal_plan: { meals: [{
                 id: @meal_1.id, meal_plan_id: @meal_plan.id, meal_items: [
                    { meal_id: @meal_1.id, id: @meal_item_1.id, food_id: @food_4.id, amount: @meal_item_1.amount } ]
                  }]
                } 
              }
      end

      it "renders the json representation for the updated meal item" do
        meal_response = json_response[:meal_plan][:meals].find {|obj| obj[:id] == @meal_1.id }
        meal_item_response = meal_response[:meal_items].find {|obj| obj[:id] == @meal_item_1.id }
        expect(meal_item_response[:food][:id]).to eql(@food_4.id)
      end

      it { is_expected.to respond_with 200 }
    end

    context "when successfully updating by changing the amount of meal item in a meal" do
      before(:each) do
        patch :update, params: { user_id: @user.id, id: @meal_plan.id,
              meal_plan: { meals: [{
                 id: @meal_1.id, meal_plan_id: @meal_plan.id, meal_items: [
                    { meal_id: @meal_1.id, id: @meal_item_1.id, food_id: @meal_item_1.food_id, amount: 1000} ]
                  }]
                } 
              }
      end

      it "renders the json representation for the updated meal item" do
        meal_response = json_response[:meal_plan][:meals].find {|obj| obj[:id] == @meal_1.id }
        meal_item_response = meal_response[:meal_items].find {|obj| obj[:id] == @meal_item_1.id }
        expect(meal_item_response[:amount].to_i).to eql(1000)
      end

      it { is_expected.to respond_with 200 }
    end

    # context "when is not updated" do
    #   before(:each) do
    #     patch :update, params: { user_id: @user.id, id: @meal_plan.id,
    #           meal_plan: { calories: "two hundred" } }
    #   end

    #   it "renders an errors json" do
    #     meal_plan_response = json_response
    #     expect(meal_plan_response).to have_key(:errors)
    #   end

    #   it "renders the json errors on whye the user could not be created" do
    #     meal_plan_response = json_response
    #     expect(meal_plan_response[:errors][:calories]).to include "is not a number"
    #   end

    #   it { is_expected.to respond_with 422 }
    # end
  end

  describe "DELETE #destroy" do
    before(:each) do
      @user = FactoryGirl.create :user
      @meal_plan = FactoryGirl.create :meal_plan, user: @user
      api_authorization_header @user.auth_token
      delete :destroy, params: { user_id: @user.id, id: @meal_plan.id }
    end

    it { is_expected.to respond_with 204 }
  end

end