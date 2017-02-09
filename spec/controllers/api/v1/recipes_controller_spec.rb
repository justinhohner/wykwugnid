require 'rails_helper'

RSpec.describe API::V1::RecipesController, type: :controller do
  
  describe "GET #index" do
    before(:each) do
      4.times { FactoryGirl.create :recipe }
    end
    context "when is not receiving any product_ids parameter" do
      before(:each) do
        get :index
      end

      it "returns 4 records from the database" do
        recipes_response = json_response[:recipes]
        expect(recipes_response.size).to eq(4)
      end

      # it "returns the user object into each recipe" do
      #   recipes_response = json_response[:recipes]
      #   recipes_response.each do |recipe_response|
      #     expect(recipe_response[:user]).to be_present
      #   end
      # end

      it { is_expected.to respond_with 200 }

    end

    # context "when recipe_ids parameter is sent" do
    #   before(:each) do
    #     @user = FactoryGirl.create :user
    #     3.times { FactoryGirl.create :recipe, user: @user }
    #     get :index, params: { recipe_ids: @user.recipe_ids }
    #   end

    #   it "returns just the recipes that belong to the user" do
    #     recipes_response = json_response[:recipes]
    #     recipes_response.each do |recipe_response|
    #       expect(recipe_response[:user][:email]).to eql @user.email
    #     end
    #   end
    # end

  end

  describe "GET #show" do
    before(:each) do
      @recipe = FactoryGirl.create :recipe
      get :show, params: { id: @recipe.id }
    end

    it "returns the information about a reporter on a hash" do
      recipe_response = json_response[:recipe]
      expect(recipe_response[:title]).to eql @recipe.title
    end

    # it "has the user as a embeded object" do
    #   recipe_response = json_response[:recipe]
    #   expect(recipe_response[:user][:email]).to eql @recipe.user.email
    # end

    it { is_expected.to respond_with 200 }
  end

  describe "POST #create" do
    context "when is successfully created with ingredients" do
      before(:each) do
        user = FactoryGirl.create :user
        #@recipe_attributes = FactoryGirl.attributes_for :recipe
        @food_1 = FactoryGirl.create :food
        @food_2 = FactoryGirl.create :food
        @recipe_attributes = { title: 'new title', ingredients: [
          {amount:2, food_id: @food_1.id},
          {amount:1, food_id: @food_2.id}
        ] }
        api_authorization_header user.auth_token
        post :create, params: { user_id: user.id, recipe: @recipe_attributes }
      end

      it "renders the json representation for the recipe record just created" do
        recipe_response = json_response[:recipe]
        expect(recipe_response[:title]).to eql @recipe_attributes[:title]
      end

      it { is_expected.to respond_with 201 }
    end

    context "when is not created" do
      before(:each) do
        user = FactoryGirl.create :user
        @invalid_recipe_attributes = { calories: "My Food" } # Title must be included. Calories isn't actually whitelisted.
        api_authorization_header user.auth_token
        post :create, params: { user_id: user.id, recipe: @invalid_recipe_attributes }
      end

      it "renders an errors json" do
        recipe_response = json_response
        expect(recipe_response).to have_key(:errors)
      end

      it "renders the json errors on why the user could not be created" do
        recipe_response = json_response
        expect(recipe_response[:errors][:title]).to include "can't be blank"
      end

      it { is_expected.to respond_with 422 }
    end
  end

  describe "PUT/PATCH #update" do
    before(:each) do
      @user = FactoryGirl.create :user
      @recipe = FactoryGirl.create :recipe, user: @user
      @food = FactoryGirl.create :food
      @ingredient = FactoryGirl.create :ingredient, { recipe: @recipe, food: @food }
      api_authorization_header @user.auth_token
    end

    context "when is successfully updated" do
      before(:each) do
        patch :update, params: { user_id: @user.id, id: @recipe.id,
              recipe: { title: "An expensive TV" } }
      end

      it "renders the json representation for the updated user" do
        recipe_response = json_response[:recipe]
        expect(recipe_response[:title]).to eql "An expensive TV"
      end

      it { is_expected.to respond_with 200 }
    end

    context "when ingredients are successfully updated" do
      before(:each) do
        patch :update, params: { user_id: @user.id, id: @recipe.id,
              recipe: { ingredients: [{id: @ingredient.id, amount: 50, food_id: @food.id}] } }
      end

      it "renders the json representation for the updated ingredient" do
        # Taking the first ingredient, since there's only one.
        recipe_response = json_response[:recipe][:ingredients][0][:amount]
        expect(recipe_response.to_i).to eql 50
      end

      it { is_expected.to respond_with 200 }
    end

    context "when is not updated" do
      before(:each) do
        patch :update, params: { user_id: @user.id, id: @recipe.id,
              recipe: { title: nil } }
      end

      it "renders an errors json" do
        recipe_response = json_response

        expect(recipe_response).to have_key(:errors)
      end

      it "renders the json errors on whye the user could not be created" do
        recipe_response = json_response
        expect(recipe_response[:errors][:title]).to include "can't be blank"
      end

      it { is_expected.to respond_with 422 }
    end
  end

  describe "DELETE #destroy" do
    before(:each) do
      @user = FactoryGirl.create :user
      @recipe = FactoryGirl.create :recipe, user: @user
      api_authorization_header @user.auth_token
      delete :destroy, params: { user_id: @user.id, id: @recipe.id }
    end

    it { is_expected.to respond_with 204 }
  end
end
