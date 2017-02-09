require 'rails_helper'

RSpec.describe API::V1::FavoritesController, type: :controller do
  # describe "Post #MyFoods" do
  #   before(:each) do
  #     @user = FactoryGirl.create :user
  #     api_authorization_header @user.auth_token
  #     @my_foods = @user.sources.create(title:'My Foods')
  #     4.times do 
  #       @food = FactoryGirl.create :food
  #       @my_foods.source_items.create(food_id: @food.id)
  #     end 
  #   end
  #   context "when is not receiving any product_ids parameter" do
  #     before(:each) do
  #       binding.pry
  #       post :foods, params: { user_id: @user.id }
  #     end

  #     it "returns 4 records from the database" do
  #       source_items_response = json_response[:source][:source_items]        
  #       expect(source_items_response.size).to eq(4)
  #     end
  #     it { is_expected.to respond_with 200 }
  #   end
  # end

  # describe "Post #MyMenuItems" do
  #   before(:each) do
  #     @user = FactoryGirl.create :user
  #     api_authorization_header @user.auth_token
  #     @my_foods = @user.sources.create(title:'My Menu Items')
  #     @restaurant = FactoryGirl.create :restaurant
  #     4.times do 
  #       @food = FactoryGirl.create :menu_item, restaurant: @restaurant
  #       @my_foods.source_items.create(food_id: @food.id)
  #     end 
  #   end
  #   context "when is not receiving any product_ids parameter" do
  #     before(:each) do
  #       post :menu_items, params: { user_id: @user.id }
  #     end
  #     it "returns 4 records from the database" do
  #       source_items_response = json_response[:source][:source_items]
  #       expect(source_items_response.size).to eq(4)
  #     end
  #     it { is_expected.to respond_with 200 }
  #   end
  # end

  # describe "Post #MyRecipes" do
  #   before(:each) do
  #     @user = FactoryGirl.create :user
  #     api_authorization_header @user.auth_token
  #     @my_recipes = @user.sources.create(title:'My Recipes')
  #     4.times do 
  #       @food = FactoryGirl.create :recipe
  #       @my_recipes.source_items.create(food_id: @food.id)
  #     end 
  #   end
  #   context "when is not receiving any product_ids parameter" do
  #     before(:each) do
  #       post :recipes, params: { user_id: @user.id }
  #     end

  #     it "returns 4 records from the database" do
  #       source_items_response = json_response[:source][:source_items]        
  #       expect(source_items_response.size).to eq(4)
  #     end
  #     it { is_expected.to respond_with 200 }
  #   end
  # end

  describe "POST #create" do
    context "when is successfully created" do
      before(:each) do
        @user = FactoryGirl.create :user
        @source_attributes = FactoryGirl.attributes_for :source, personal: true
        api_authorization_header @user.auth_token
        post :create, params: { user_id: @user.id, source: @source_attributes }
      end

      it "renders the json representation for the source record just created" do
        source_response = json_response[:source]
        expect(source_response[:title]).to eql @source_attributes[:title]
        expect(source_response[:personal]).to eql true
      end

      it { is_expected.to respond_with 201 }
    end

    context "when is successfully created with source_items" do
      before(:each) do
        @user = FactoryGirl.create :user
        @food_1 = FactoryGirl.create :food
        @food_2 = FactoryGirl.create :food
        @source_attributes = { title: 'new title', personal: true,
          source_items: [
            {food_id: @food_1.id},
            {food_id: @food_2.id}
          ] }
        api_authorization_header @user.auth_token
        post :create, params: { user_id: @user.id, source: @source_attributes }
      end

      it "renders the json representation for the source record just created" do
        source_response = json_response[:source]
        expect(source_response[:title]).to eql @source_attributes[:title]
        expect(source_response[:personal]).to eql true
      end

      it "renders the json of 2 source_items records" do
        source_response = json_response[:source]
        expect(source_response[:source_items].size).to eq(2)
      end

      it { is_expected.to respond_with 201 }
    end
  end

  describe "PUT/PATCH #update" do

    context "when is successfully updated" do
      before(:each) do
        @user = FactoryGirl.create :user
        @source = @user.sources.create()
        api_authorization_header @user.auth_token
        patch :update, params: { user_id: @user.id, id: @source.id,
              source: { title: "An expensive TV" } }
      end

      it "renders the json representation for the updated user" do
        source_response = json_response[:source]
        expect(source_response[:title]).to eql "An expensive TV"
      end

      it { is_expected.to respond_with 200 }
    end

    context "when source items are successfully updated" do
      before(:each) do
        @user = FactoryGirl.create :user
        @source = @user.sources.create()
        @food1 = FactoryGirl.create :food
        @food2 = FactoryGirl.create :food
        @source_item1 = FactoryGirl.create :source_item, { source_id: @source.id, food_id: @food1.id }
        @source_item2 = FactoryGirl.create :source_item, { source_id: @source.id, food_id: @food2.id }
        api_authorization_header @user.auth_token
        patch :update, params: { user_id: @user.id, id: @source.id,
              source: { source_items: [{id: @source_item2.id, food_id: @food2.id, _destroy: 1}]}}
      end

      it "renders the json representation for the updated source item" do
        # Taking the first source item, since there's only one.
        source_response = json_response[:source]
        expect(source_response[:source_items].size).to eql 1
      end

      it { is_expected.to respond_with 200 }
    end
  end

  describe "DELETE #destroy" do
    before(:each) do
      @user = FactoryGirl.create :user
      @source = @user.sources.create()
      api_authorization_header @user.auth_token
      delete :destroy, params: { user_id: @user.id, id: @source.id }
    end

    it { is_expected.to respond_with 204 }
  end

end
