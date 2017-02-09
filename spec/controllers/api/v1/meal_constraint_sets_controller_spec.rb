require 'rails_helper'

RSpec.describe API::V1::MealConstraintSetsController, type: :controller do

  describe "GET #index" do
    before(:each) do
      @user = FactoryGirl.create :user
      @daily_constraint_set = FactoryGirl.create :daily_constraint_set
      4.times { FactoryGirl.create :meal_constraint_set, user_id: @user.id, daily_constraint_set_id: @daily_constraint_set.id}
    end

    context "when is not receiving any product_ids parameter" do
      before(:each) do
        get :index, params: {user_id: @user.id}
      end

      it "returns 4 records from the database" do
        meal_constraint_sets_response = json_response[:meal_constraint_sets]
        expect(meal_constraint_sets_response.size).to eq(4)
      end

      it "returns the user id for each meal_constraint_set" do
        meal_constraint_sets_response = json_response[:meal_constraint_sets]
        meal_constraint_sets_response.each do |meal_constraint_set_response|
          expect(meal_constraint_set_response[:user_id]).to be_present
          expect(meal_constraint_set_response[:user_id]).to eq @user.id
        end
      end

      it "returns the daily_constraint_set id for each meal_constraint_set" do
        meal_constraint_sets_response = json_response[:meal_constraint_sets]
        meal_constraint_sets_response.each do |meal_constraint_set_response|
          expect(meal_constraint_set_response[:daily_constraint_set_id]).to be_present
          expect(meal_constraint_set_response[:daily_constraint_set_id]).to eq @daily_constraint_set.id
        end
      end

      it { is_expected.to respond_with 200 }
    end
  end

  describe "GET #show" do
    before(:each) do
      @user = FactoryGirl.create :user
      @daily_constraint_set = FactoryGirl.create :daily_constraint_set
      @meal_constraint_set = FactoryGirl.create :meal_constraint_set, user_id: @user.id, daily_constraint_set_id: @daily_constraint_set.id
      get :show, params: { user_id: @user.id, id: @meal_constraint_set.id }
    end

    it "returns the information about a reporter on a hash" do
      meal_constraint_set_response = json_response[:meal_constraint_set]
      expect(meal_constraint_set_response[:title]).to eql @meal_constraint_set.title
    end

    it "has the user id" do
      meal_constraint_set_response = json_response[:meal_constraint_set]
      expect(meal_constraint_set_response[:user_id]).to eql @user.id
      expect(meal_constraint_set_response[:user_id]).to eql @meal_constraint_set.user.id
    end

    it "has the daily_constraint_set id" do
      meal_constraint_set_response = json_response[:meal_constraint_set]
      expect(meal_constraint_set_response[:daily_constraint_set_id]).to eql @daily_constraint_set.id
      expect(meal_constraint_set_response[:daily_constraint_set_id]).to eql @meal_constraint_set.daily_constraint_set.id
    end

    it { is_expected.to respond_with 200 }
  end

  describe "POST #create" do
    before(:each) do
      @user = FactoryGirl.create :user
      api_authorization_header @user.auth_token
      @daily_constraint_set = FactoryGirl.create :daily_constraint_set
    end

    context "when is successfully created" do
      before(:each) do
        @meal_constraint_set_attributes = FactoryGirl.attributes_for :meal_constraint_set, user_id: @user.id
        # Need to ensure daily_constraint_set exists
        @meal_constraint_set_attributes[:daily_constraint_set_id] = @daily_constraint_set.id 
        post :create, params: { user_id: @user.id, meal_constraint_set: @meal_constraint_set_attributes }
      end

      it "renders the json representation for the meal_constraint_set record just created" do
        meal_constraint_set_response = json_response[:meal_constraint_set]
        expect(meal_constraint_set_response[:target_carbohydrates].to_i).to eql @meal_constraint_set_attributes[:target_carbohydrates]
      end

      it { is_expected.to respond_with 201 }
    end

    context "when is not created" do
      before(:each) do
        #notice I'm not including the email
        @invalid_meal_constraint_set_attributes = { user_id: @user.id,
                                     max_calories: "200 Calories" }
        post :create, params: { user_id: @user.id, meal_constraint_set: @invalid_meal_constraint_set_attributes }
      end

      it "renders an errors json" do
        meal_constraint_set_response = json_response
        expect(meal_constraint_set_response).to have_key(:errors)
      end

      it "renders the json errors on why the meal_constraint_set could not be created" do
        meal_constraint_set_response = json_response
        expect(meal_constraint_set_response[:errors][:daily_constraint_set]).to include "must exist"
      end

        it "renders the json errors on why the meal_constraint_set could not be created" do
        meal_constraint_set_response = json_response
        expect(meal_constraint_set_response[:errors][:max_calories]).to include "is not a number"
      end

      it { is_expected.to respond_with 422 }
    end
  end

  describe "PUT/PATCH #update" do
    before(:each) do
        @user = FactoryGirl.create :user
        api_authorization_header @user.auth_token
        @daily_constraint_set = FactoryGirl.create :daily_constraint_set
        @meal_constraint_set = FactoryGirl.create :meal_constraint_set, user_id: @user.id
        # Need to ensure daily_constraint_set exists
        @meal_constraint_set.daily_constraint_set_id = @daily_constraint_set.id 
    end

    context "when is successfully updated" do
      before(:each) do
        patch :update, params: { user_id: @user.id, id: @meal_constraint_set.id,
                         meal_constraint_set: { title: "new title" } }
      end

      it "renders the json representation for the updated meal_constraint_set" do
        meal_constraint_set_response = json_response[:meal_constraint_set]
        expect(meal_constraint_set_response[:title]).to eql "new title"
      end

      it { is_expected.to respond_with 200 }
    end

    context "when is not created" do
      before(:each) do
        patch :update, params: { user_id: @user.id, id: @meal_constraint_set.id,
                         meal_constraint_set: { daily_constraint_set_id: "bad id" } }
      end

      it "renders an errors json" do
        meal_constraint_set_response = json_response
        expect(meal_constraint_set_response).to have_key(:errors)
      end

      it "renders the json errors on whye the meal_constraint_set could not be created" do
        meal_constraint_set_response = json_response
        expect(meal_constraint_set_response[:errors][:daily_constraint_set]).to include "must exist"
      end

      it { is_expected.to respond_with 422 }
    end
  end

  describe "DELETE #destroy" do
    before(:each) do
        @user = FactoryGirl.create :user
        api_authorization_header @user.auth_token
        @meal_constraint_set = FactoryGirl.create :meal_constraint_set, user_id: @user.id
        delete :destroy, params: { user_id: @user.id, id: @meal_constraint_set.id }
    end

    it { is_expected.to respond_with 204 }

  end

end
