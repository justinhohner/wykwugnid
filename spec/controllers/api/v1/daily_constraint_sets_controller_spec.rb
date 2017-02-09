require 'rails_helper'

RSpec.describe API::V1::DailyConstraintSetsController, type: :controller do
  
  describe "GET #index" do
    before(:each) do
      @user = FactoryGirl.create :user
      4.times { FactoryGirl.create :daily_constraint_set, user: @user}
    end
    context "when is not receiving any product_ids parameter" do
      before(:each) do
        get :index, params: {user_id: @user.id}
      end

      it "returns 4 records from the database" do
        daily_constraint_sets_response = json_response[:daily_constraint_sets]
        expect(daily_constraint_sets_response.size).to eq(4)
      end

      it "returns the user object into each daily_constraint_set" do
        daily_constraint_sets_response = json_response[:daily_constraint_sets]
        daily_constraint_sets_response.each do |daily_constraint_set_response|
          expect(daily_constraint_set_response[:user_id]).to be_present
          expect(daily_constraint_set_response[:user_id]).to eq @user.id
        end
      end

      it { is_expected.to respond_with 200 }

    end

    ### TO USE THIS KIND OF FEATURE. I NEED TO ADD SOMETHING LIKE THE FOLLOWING TO THE DAILY_CONSTRAINT_SET MODEL
    ### daily_constraint_sets = params[:daily_constraint_set_ids].present? ? DailyCononstratinsSet.find(params[:recipe_ids]) : Recipe.all
    # context "when daily_constraint_set_ids parameter is sent" do
    #   before(:each) do
    #     get :index, params: { user_id: @user.id, daily_constraint_set_ids: @user.daily_constraint_set_ids }
    #   end

    #   it "returns just the daily_constraint_sets that belong to the user" do
    #     daily_constraint_sets_response = json_response[:daily_constraint_sets]
    #     daily_constraint_sets_response.each do |daily_constraint_set_response|
    #       expect(daily_constraint_set_response[:user_id]).to eql @user.id
    #     end
    #   end
    # end
  end

  describe "GET #show" do
    before(:each) do
      @user = FactoryGirl.create :user
      @daily_constraint_set = FactoryGirl.create :daily_constraint_set, user: @user
      get :show, params: { user_id: @user.id, id: @daily_constraint_set.id }
    end

    it "returns the information about a reporter on a hash" do
      daily_constraint_set_response = json_response[:daily_constraint_set]
      expect(daily_constraint_set_response[:title]).to eql @daily_constraint_set.title
    end

    it "has the user id" do
      daily_constraint_set_response = json_response[:daily_constraint_set]
      expect(daily_constraint_set_response[:user_id]).to eql @user.id
      expect(daily_constraint_set_response[:user_id]).to eql @daily_constraint_set.user.id
    end

    it { is_expected.to respond_with 200 }
  end

  describe "POST #create" do
    context "when is successfully created with ingredients" do
      before(:each) do
        @user = FactoryGirl.create :user
        api_authorization_header @user.auth_token
        @daily_constraint_set = FactoryGirl.create :daily_constraint_set, user_id: @user.id
        @meal_constraint_set_1 = FactoryGirl.attributes_for :meal_constraint_set, { daily_constraint_set_id: nil, user_id: nil }
        @meal_constraint_set_2 = FactoryGirl.attributes_for :meal_constraint_set, { daily_constraint_set_id: nil, user_id: nil }
        @daily_constraint_set_attributes = {meal_constraint_sets: [@meal_constraint_set_1, @meal_constraint_set_2]}
        post :create, params: { user_id: @user.id, daily_constraint_set: @daily_constraint_set_attributes }
      end

      it "renders the json representation for the recipe record just created" do
        daily_constraint_set_response = json_response[:daily_constraint_set]
        expect(daily_constraint_set_response[:title]).to eql @daily_constraint_set_attributes[:title]
      end

      it "renders the json of 2 meal_items records" do
        daily_constraint_set_response = json_response[:daily_constraint_set]
        expect(daily_constraint_set_response[:meal_constraint_sets].size).to eq(2)
      end

      it { is_expected.to respond_with 201 }
    end

    # context "when is successfully created with meals from other meal plans and no meal items in the meals" do
    #   before(:each) do
    #     user = FactoryGirl.create :user
    #     @meal_1 = FactoryGirl.create :meal
    #     @meal_2 = FactoryGirl.create :meal
    #     @meal_plan_attributes = { title: 'new title', meals: [@meal_1, @meal_2]}
    #     api_authorization_header user.auth_token
    #     post :create, params: { user_id: user.id, meal_plan: @meal_plan_attributes }
    #   end

    #   ###################################################################
    #   # it "renders the json representation for the meal_plan record just created" do
    #   #   meal_plan_response = json_response[:meal_plan]
    #   #   expect(meal_plan_response[:title]).to eql @meal_plan_attributes[:title]
    #   # end

    #   # it "renders the json of 2 meals records" do
    #   #   meal_plan_response = json_response[:meal_plan][:meals]
    #   #   expect(meal_plan_response.size).to eq(2)
    #   # end

    #   # it { is_expected.to respond_with 201 }
    #   ###################################################################
    # end

    context "when is not created" do
      before(:each) do
        @user = FactoryGirl.create :user
        api_authorization_header @user.auth_token
        @invalid_daily_constraint_set_attributes = FactoryGirl.attributes_for :daily_constraint_set, { user_id: @user.id, max_calories: "200 calories" }
        post :create, params: { user_id: @user.id, daily_constraint_set: @invalid_daily_constraint_set_attributes }
      end

      it "renders an errors json" do
        daily_constraint_set_response = json_response
        expect(daily_constraint_set_response).to have_key(:errors)
      end

      it "renders the json errors on why the user could not be created" do
        daily_constraint_set_response = json_response
        expect(daily_constraint_set_response[:errors][:max_calories]).to include "is not a number"
      end

      it { is_expected.to respond_with 422 }
    end
  end

  describe "PUT/PATCH #update" do
    before(:each) do
      @user = FactoryGirl.create :user
      api_authorization_header @user.auth_token
      @daily_constraint_set = FactoryGirl.create :daily_constraint_set, user: @user
      @meal_constraint_set = FactoryGirl.create :meal_constraint_set, { daily_constraint_set_id: @daily_constraint_set.id, user_id: @user.id }
    end

    context "when is successfully updated" do
      before(:each) do
        patch :update, params: { user_id: @user.id, id: @daily_constraint_set.id,
              daily_constraint_set: { title: "An expensive TV" } }
      end

      it "renders the json representation for the updated user" do
        daily_constraint_set_response = json_response[:daily_constraint_set]
        expect(daily_constraint_set_response[:title]).to eql "An expensive TV"
      end

      it { is_expected.to respond_with 200 }
    end

    context "when meal_constraint_sets are successfully updated" do
      before(:each) do
        patch :update, params: { user_id: @user.id, id: @daily_constraint_set.id,
              daily_constraint_set: { meal_constraint_sets: [{id: @meal_constraint_set.id, min_calories: 400}] } }
      end

      it "renders the json representation for the updated meal_constraint_set" do
        # Taking the first meal_constraint_set, since there's only one.
        daily_constraint_set_response = json_response[:daily_constraint_set][:meal_constraint_sets][0][:min_calories]
        expect(daily_constraint_set_response.to_i).to eql 400
      end

      it { is_expected.to respond_with 200 }
    end

    context "when is not updated" do
      before(:each) do
        patch :update, params: { user_id: @user.id, id: @daily_constraint_set.id,
              daily_constraint_set: { max_calories: "100 Calories" } }
      end

      it "renders an errors json" do
        daily_constraint_set_response = json_response

        expect(daily_constraint_set_response).to have_key(:errors)
      end

      it "renders the json errors on whye the user could not be created" do
        daily_constraint_set_response = json_response
        expect(daily_constraint_set_response[:errors][:max_calories]).to include "is not a number"
      end

      it { is_expected.to respond_with 422 }
    end
  end

  describe "DELETE #destroy" do
    before(:each) do
      @user = FactoryGirl.create :user
      @daily_constraint_set = FactoryGirl.create :daily_constraint_set, user: @user
      api_authorization_header @user.auth_token
      delete :destroy, params: { user_id: @user.id, id: @daily_constraint_set.id }
    end

    it { is_expected.to respond_with 204 }
  end

  describe "GET #today" do
    before(:each) do
      @user = FactoryGirl.create :user
      api_authorization_header @user.auth_token
      @daily_constraint_set = FactoryGirl.create :daily_constraint_set, {user: @user, primary: true}
      @meal_constraint_set_1 = FactoryGirl.create :meal_constraint_set, { daily_constraint_set_id: @daily_constraint_set.id, user_id: @user.id }
      @meal_constraint_set_2 = FactoryGirl.create :meal_constraint_set, { daily_constraint_set_id: @daily_constraint_set.id, user_id: @user.id }
    end
    context "when is not receiving any product_ids parameter" do
      before(:each) do
        get :today, params: {user_id: @user.id}
      end
      it "renders an errors json" do
        daily_constraint_set_response = json_response
        binding.pry
      end
      it { is_expected.to respond_with 200 }
    end
  end

end
