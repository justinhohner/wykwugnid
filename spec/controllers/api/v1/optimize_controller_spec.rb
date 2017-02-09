require 'rails_helper'

RSpec.describe API::V1::OptimizeController, type: :controller do
    
  describe "Index #index" do
    context "when no meal plan exists for today, creates an empty meal plan" do
      before(:each) do
        @user = FactoryGirl.create :user
        api_authorization_header @user.auth_token
        @dcs = FactoryGirl.create :daily_constraint_set, {user_id: @user.id, primary: true}
        @mcs1 = FactoryGirl.create :meal_constraint_set, {user_id: @user.id, daily_constraint_set_id: @dcs.id}
        @mcs2 = FactoryGirl.create :meal_constraint_set, {user_id: @user.id, daily_constraint_set_id: @dcs.id}
        @mcs3 = FactoryGirl.create :meal_constraint_set, {user_id: @user.id, daily_constraint_set_id: @dcs.id}
        get :index, params: { user_id: @user.id, date: Date.today.strftime("%m/%d/%Y")}
      end

      it "renders the json representation for a newly created meal plan for today with correct user_id" do
        meal_plan_response = json_response[:meal_plan]
        expect(meal_plan_response[:user_id]).to eql(@user.id)
      end

      it "renders the json representation for a newly created meal plan for today with correct date" do
        meal_plan_response = json_response[:meal_plan]
        expect(meal_plan_response[:used_at]).to eql(Date.today.to_s)
      end

      it { is_expected.to respond_with 200 }
    end

    context "when a meal plan already exists for today, returns the correct meal play for today" do
      before(:each) do
        @user = FactoryGirl.create :user
        @meal_plan = FactoryGirl.create :meal_plan, { user: @user, used_at: Date.tomorrow }
        api_authorization_header @user.auth_token
        get :index, params: { user_id: @user.id, date: Date.tomorrow.strftime("%m/%d/%Y") }
      end

      it "renders the json representation for the existing meal plan with the correct id" do
        meal_plan_response = json_response[:meal_plan]
        expect(meal_plan_response[:id]).to eql(@meal_plan.id)
      end

      it "renders the json representation for the existing meal plan for today with correct user_id" do
        meal_plan_response = json_response[:meal_plan]
        expect(meal_plan_response[:user_id]).to eql(@user.id)
      end

      it "renders the json representation for the existing meal plan for today with correct date" do
        meal_plan_response = json_response[:meal_plan]
        expect(meal_plan_response[:used_at]).to eql(Date.tomorrow.to_s)
      end

      it { is_expected.to respond_with 200 }
    end
  end

  describe "Create #create" do

    context "Empty Meal Plan" do
      before(:each) do
        @user = FactoryGirl.create :user
        api_authorization_header @user.auth_token

        # FOODS
        @apple = FactoryGirl.create :food, {title: "apple", calories: 52, fat: 0.2, carbohydrates: 13.8, protein: 0.3}
        @avocado = FactoryGirl.create :food, {title: "avocado", calories: 160, fat: 15, carbohydrates: 2, protein: 2}
        @banana = FactoryGirl.create :food, {title: "banana", calories: 105, fat: 0.4, carbohydrates: 24, protein:1.3}
        @blueberry = FactoryGirl.create :food, {title: "blueberry", calories: 84.4, fat: 0.5, carbohydrates: 21.4, protein:1.1}
        @orange = FactoryGirl.create :food, {title: "orange", calories: 47, fat: 0.1, carbohydrates: 11.8, protein:0.9}
        @eggs = FactoryGirl.create :food, {title: "eggs", calories: 77, fat: 5, carbohydrates: 0, protein:6}
        @chicken = FactoryGirl.create :food, {title: "chicken", calories: 33.2, fat: 0.2, carbohydrates: 0.9, protein:7.1}
        @lamb = FactoryGirl.create :food, {title: "lamb", calories: 345, fat: 27.7, carbohydrates: 0, protein:33.1}
        @almond = FactoryGirl.create :food, {title: "almond", calories: 167, fat: 14.8, carbohydrates: 5.4, protein:6.2}
        @chia_seed = FactoryGirl.create :food, {title: "chia seed", calories: 137, fat: 9, carbohydrates: 1, protein:4}
        @coconut = FactoryGirl.create :food, {title: "coconut", calories: 99.1, fat: 9.4, carbohydrates: 4.3, protein:0.9}
        @peanut = FactoryGirl.create :food, {title: "peanut", calories: 172, fat: 15.7, carbohydrates: 6.2, protein:4.3}
        @asparagus = FactoryGirl.create :food, {title: "asparagus", calories: 26.8, fat: 0.2, carbohydrates: 5.3, protein:2.9}
        @broccoli = FactoryGirl.create :food, {title: "broccoli", calories: 30.9, fat: 0.3, carbohydrates: 6.0, protein: 2.6}
        @carrot = FactoryGirl.create :food, {title: "carrot", calories: 35, fat: 0.1, carbohydrates: 8.2, protein: 0.6}
        @cauliflower = FactoryGirl.create :food, {title: "cauliflower", calories: 25, fat: 0.1, carbohydrates: 5.3, protein: 2.0}
        @cucumber = FactoryGirl.create :food, {title: "cucumber", calories: 15, fat: 0.1, carbohydrates: 3.6, protein: 0.7}
        @kale = FactoryGirl.create :food, {title: "kale", calories: 33.5, fat: 0.5, carbohydrates: 6.7, protein:2.2}
        @onion = FactoryGirl.create :food, {title: "onion", calories: 64, fat: 0.2, carbohydrates: 14.9, protein:1.8}
        @tomatoe = FactoryGirl.create :food, {title: "tomatoe", calories: 70, fat: 0.8, carbohydrates: 15, protein:3.8}
        @salmon = FactoryGirl.create :food, {title: "salmon", calories: 33.6, fat: 1.1, carbohydrates: 0, protein:5.6}
        @sardine = FactoryGirl.create :food, {title: "sardine", calories: 58.2, fat: 3.2, carbohydrates: 0, protein:6.9}
        @scallop = FactoryGirl.create :food, {title: "scallop", calories: 140, fat: 1, carbohydrates: 5, protein:27}
        @shrimp = FactoryGirl.create :food, {title: "shrimp", calories: 100, fat: 1, carbohydrates: 0, protein:21}
        @trout = FactoryGirl.create :food, {title: "trout", calories: 109, fat: 0, carbohydrates: 4.3, protein: 16.5}
        @tuna = FactoryGirl.create :food, {title: "tuna", calories: 28.8, fat: 0.3, carbohydrates: 0, protein:6.2}
        @brown_rice = FactoryGirl.create :food, {title: "brown rice", calories: 104, fat: 0.8, carbohydrates: 21.6, protein: 2.2}
        @white_rice = FactoryGirl.create :food, {title: "white rice", calories: 27.2, fat: 0.1, carbohydrates: 5.9, protein: 0.6}
        @oats = FactoryGirl.create :food, {title: "oats", calories: 109, fat: 1.9, carbohydrates: 18.6, protein: 4.7}
        @quinoa = FactoryGirl.create :food, {title: "quinoa", calories: 33.6, fat: 0.5, carbohydrates: 6.0, protein:1.2}
        @ezekial_bread = FactoryGirl.create :food, {title: "ezekial bread", calories: 80, fat: 0.5, carbohydrates: 14, protein:4}
        @pita_bread = FactoryGirl.create :food, {title: "pita bread", calories: 170, fat: 35.2, carbohydrates: 1.7, protein: 6.3}
        @green_beans = FactoryGirl.create :food, {title: "green beans", calories: 34.1, fat: 0.1, carbohydrates: 7.8, protein:2.0}
        @kidney_beans = FactoryGirl.create :food, {title: "kidney beans", calories: 215, fat: 0.9, carbohydrates: 42, protein: 13.5}
        @lentil = FactoryGirl.create :food, {title: "lentil", calories: 49.4, fat: 0.1, carbohydrates: 8.4, protein: 3.6}
        @cheese = FactoryGirl.create :food, {title: "cheese", calories: 101, fat: 8.4, carbohydrates: 0.4, protein: 8}
        @milk = FactoryGirl.create :food, {title: "milk", calories: 61, fat: 3.3, carbohydrates: 4.8, protein: 3.2}
        @yoghurt = FactoryGirl.create :food, {title: "yoghurt", calories: 61, fat: 3.3, carbohydrates: 4.7, protein: 3.5}
        @sweet_potato = FactoryGirl.create :food, {title: "sweet potato", calories: 54, fat: 0.1, carbohydrates: 12.4, protein: 1.2}

        # RECIPES
        # Recipe 1
        @recipe_1 = FactoryGirl.create :recipe, {user_id: @user.id, title: 'Recipe NUmber 1'}
        @ingredient_1_1 = FactoryGirl.create :ingredient, {recipe_id: @recipe_1.id, food_id: @apple.id, amount: 0.3}
        @ingredient_1_2 = FactoryGirl.create :ingredient, {recipe_id: @recipe_1.id, food_id: @avocado.id, amount: 0.7}
        @ingredient_1_3 = FactoryGirl.create :ingredient, {recipe_id: @recipe_1.id, food_id: @shrimp.id, amount: 0.4}
        @recipe_1 = @ingredient_1_3.recipe

        # Recipe 2
        @recipe_2 = FactoryGirl.create :recipe, {user_id: @user.id, title: 'Recipe NUmber 2'}
        @ingredient_2_1 = FactoryGirl.create :ingredient, {recipe_id: @recipe_2.id, food_id: @ezekial_bread.id, amount: 0.5}
        @ingredient_2_2 = FactoryGirl.create :ingredient, {recipe_id: @recipe_2.id, food_id: @milk.id, amount: 0.7}
        @ingredient_2_3 = FactoryGirl.create :ingredient, {recipe_id: @recipe_2.id, food_id: @kidney_beans.id, amount: 0.5}
        @recipe_2 = @ingredient_2_3.recipe

        # Recipe 3
        @recipe_3 = FactoryGirl.create :recipe, {user_id: @user.id, title: 'Recipe NUmber 3'}
        @ingredient_3_1 = FactoryGirl.create :ingredient, {recipe_id: @recipe_3.id, food_id: @onion.id, amount: 0.5}
        @ingredient_3_2 = FactoryGirl.create :ingredient, {recipe_id: @recipe_3.id, food_id: @chia_seed.id, amount: 0.7}
        @ingredient_3_3 = FactoryGirl.create :ingredient, {recipe_id: @recipe_3.id, food_id: @blueberry.id, amount: 0.5}
        @recipe_3 = @ingredient_3_3.recipe

        # Recipe 4
        @recipe_4 = FactoryGirl.create :recipe, {user_id: @user.id, title: 'Recipe NUmber 4'}
        @ingredient_4_1 = FactoryGirl.create :ingredient, {recipe_id: @recipe_4.id, food_id: @sweet_potato.id, amount: 0.5}
        @ingredient_4_2 = FactoryGirl.create :ingredient, {recipe_id: @recipe_4.id, food_id: @trout.id, amount: 0.2}
        @ingredient_4_3 = FactoryGirl.create :ingredient, {recipe_id: @recipe_4.id, food_id: @orange.id, amount: 0.5}
        @recipe_4 = @ingredient_4_3.recipe

        # Recipe 5
        @recipe_5 = FactoryGirl.create :recipe, {user_id: @user.id, title: 'Recipe NUmber 5'}
        @ingredient_5_1 = FactoryGirl.create :ingredient, {recipe_id: @recipe_5.id, food_id: @yoghurt.id, amount: 0.5}
        @ingredient_5_2 = FactoryGirl.create :ingredient, {recipe_id: @recipe_5.id, food_id: @peanut.id, amount: 0.2}
        @ingredient_5_3 = FactoryGirl.create :ingredient, {recipe_id: @recipe_5.id, food_id: @asparagus.id, amount: 0.5}
        @recipe_5 = @ingredient_5_3.recipe

        # Recipe 6
        @recipe_6 = FactoryGirl.create :recipe, {user_id: @user.id, title: 'Recipe NUmber 6'}
        @ingredient_6_1 = FactoryGirl.create :ingredient, {recipe_id: @recipe_6.id, food_id: @salmon.id, amount: 0.5}
        @ingredient_6_2 = FactoryGirl.create :ingredient, {recipe_id: @recipe_6.id, food_id: @kale.id, amount: 0.5}
        @ingredient_6_3 = FactoryGirl.create :ingredient, {recipe_id: @recipe_6.id, food_id: @brown_rice.id, amount: 0.5}
        @recipe_6 = @ingredient_6_3.recipe

        # Recipe 7
        @recipe_7 = FactoryGirl.create :recipe, {user_id: @user.id, title: 'Recipe NUmber 7'}
        @ingredient_7_1 = FactoryGirl.create :ingredient, {recipe_id: @recipe_7.id, food_id: @oats.id, amount: 0.3}
        @ingredient_7_2 = FactoryGirl.create :ingredient, {recipe_id: @recipe_7.id, food_id: @sardine.id, amount: 0.3}
        @ingredient_7_3 = FactoryGirl.create :ingredient, {recipe_id: @recipe_7.id, food_id: @banana.id, amount: 0.4}
        @recipe_7 = @ingredient_7_3.recipe

        # Recipe 8
        @recipe_8 = FactoryGirl.create :recipe, {user_id: @user.id, title: 'Recipe NUmber 8'}
        @ingredient_8_1 = FactoryGirl.create :ingredient, {recipe_id: @recipe_8.id, food_id: @sweet_potato.id, amount: 0.3}
        @ingredient_8_2 = FactoryGirl.create :ingredient, {recipe_id: @recipe_8.id, food_id: @trout.id, amount: 0.4}
        @ingredient_8_3 = FactoryGirl.create :ingredient, {recipe_id: @recipe_8.id, food_id: @orange.id, amount: 0.3}
        @recipe_8 = @ingredient_8_3.recipe

        # Recipe 9
        @recipe_9 = FactoryGirl.create :recipe, {user_id: @user.id, title: 'Recipe NUmber 9'}
        @ingredient_9_1 = FactoryGirl.create :ingredient, {recipe_id: @recipe_9.id, food_id: @carrot.id, amount: 0.3}
        @ingredient_9_2 = FactoryGirl.create :ingredient, {recipe_id: @recipe_9.id, food_id: @broccoli.id, amount: 0.2}
        @ingredient_9_3 = FactoryGirl.create :ingredient, {recipe_id: @recipe_9.id, food_id: @lentil.id, amount: 0.2}
        @ingredient_9_4 = FactoryGirl.create :ingredient, {recipe_id: @recipe_9.id, food_id: @pita_bread.id, amount: 0.3}
        @recipe_9 = @ingredient_9_4.recipe

        # MENU ITEMS
        # Menu Item 1
        @menu_item_1 = FactoryGirl.create :menu_item, {title: 'Menu Item Number 1', price: 2.00, calories: 1144/4, fat: 38/4, carbohydrates: 157/4, protein: 42/4}
        @menu_item_ingredient_1_1 = FactoryGirl.create :menu_item_ingredient, {menu_item_id: @menu_item_1.id, food_id: @apple.id}
        @menu_item_ingredient_1_2 = FactoryGirl.create :menu_item_ingredient, {menu_item_id: @menu_item_1.id, food_id: @avocado.id}
        @menu_item_ingredient_1_3 = FactoryGirl.create :menu_item_ingredient, {menu_item_id: @menu_item_1.id, food_id: @shrimp.id}
        @menu_item_1 = @menu_item_ingredient_1_3.menu_item

        # Menu Item 2
        @menu_item_2 = FactoryGirl.create :menu_item, {title: 'Menu Item Number 2', price: 8.00, calories: 1144/3, fat: 38/3, carbohydrates: 157/3, protein: 42/3}
        @menu_item_ingredient_2_1 = FactoryGirl.create :menu_item_ingredient, {menu_item_id: @menu_item_2.id, food_id: @ezekial_bread.id}
        @menu_item_ingredient_2_2 = FactoryGirl.create :menu_item_ingredient, {menu_item_id: @menu_item_2.id, food_id: @milk.id}
        @menu_item_ingredient_2_3 = FactoryGirl.create :menu_item_ingredient, {menu_item_id: @menu_item_2.id, food_id: @kidney_beans.id}
        @menu_item_2 = @menu_item_ingredient_2_3.menu_item

        # Menu Item 3
        @menu_item_3 = FactoryGirl.create :menu_item, {title: 'Menu Item Number 3', price: 4.00, calories: 1144/2, fat: 38/2, carbohydrates: 157/2, protein: 42/2}
        @menu_item_ingredient_3_1 = FactoryGirl.create :menu_item_ingredient, {menu_item_id: @menu_item_3.id, food_id: @onion.id}
        @menu_item_ingredient_3_2 = FactoryGirl.create :menu_item_ingredient, {menu_item_id: @menu_item_3.id, food_id: @chia_seed.id}
        @menu_item_ingredient_3_3 = FactoryGirl.create :menu_item_ingredient, {menu_item_id: @menu_item_3.id, food_id: @blueberry.id}
        @menu_item_3 = @menu_item_ingredient_3_3.menu_item

        # Menu Item 4
        @menu_item_4 = FactoryGirl.create :menu_item, {title: 'Menu Item Number 4', price: 2.00, calories: 1144/4, fat: 38/4, carbohydrates: 157/4, protein: 42/4}
        @menu_item_ingredient_4_1 = FactoryGirl.create :menu_item_ingredient, {menu_item_id: @menu_item_4.id, food_id: @sweet_potato.id}
        @menu_item_ingredient_4_2 = FactoryGirl.create :menu_item_ingredient, {menu_item_id: @menu_item_4.id, food_id: @trout.id}
        @menu_item_ingredient_4_3 = FactoryGirl.create :menu_item_ingredient, {menu_item_id: @menu_item_4.id, food_id: @orange.id}
        @menu_item_4 = @menu_item_ingredient_4_3.menu_item

        # Menu Item 5
        @menu_item_5 = FactoryGirl.create :menu_item, {title: 'Menu Item Number 5', price: 9.00, calories: 1144/3, fat: 38/3, carbohydrates: 157/3, protein: 42/3}
        @menu_item_ingredient_5_1 = FactoryGirl.create :menu_item_ingredient, {menu_item_id: @menu_item_5.id, food_id: @yoghurt.id}
        @menu_item_ingredient_5_2 = FactoryGirl.create :menu_item_ingredient, {menu_item_id: @menu_item_5.id, food_id: @peanut.id}
        @menu_item_ingredient_5_3 = FactoryGirl.create :menu_item_ingredient, {menu_item_id: @menu_item_5.id, food_id: @asparagus.id}
        @menu_item_5 = @menu_item_ingredient_5_3.menu_item

        # Menu Item 6
        @menu_item_6 = FactoryGirl.create :menu_item, {title: 'Menu Item Number 6', price: 1.00, calories: 1144/2, fat: 38/2, carbohydrates: 157/2, protein: 42/2}
        @menu_item_ingredient_6_1 = FactoryGirl.create :menu_item_ingredient, {menu_item_id: @menu_item_6.id, food_id: @salmon.id}
        @menu_item_ingredient_6_2 = FactoryGirl.create :menu_item_ingredient, {menu_item_id: @menu_item_6.id, food_id: @kale.id}
        @menu_item_ingredient_6_3 = FactoryGirl.create :menu_item_ingredient, {menu_item_id: @menu_item_6.id, food_id: @brown_rice.id}
        @menu_item_6 = @menu_item_ingredient_6_3.menu_item

        # Menu Item 7
        @menu_item_7 = FactoryGirl.create :menu_item, {title: 'Menu Item Number 7', price: 8.00, calories: 1525/4, fat: 50/4, carbohydrates: 209/4, protein: 56/4}
        @menu_item_ingredient_7_1 = FactoryGirl.create :menu_item_ingredient, {menu_item_id: @menu_item_7.id, food_id: @oats.id}
        @menu_item_ingredient_7_2 = FactoryGirl.create :menu_item_ingredient, {menu_item_id: @menu_item_7.id, food_id: @sardine.id}
        @menu_item_ingredient_7_3 = FactoryGirl.create :menu_item_ingredient, {menu_item_id: @menu_item_7.id, food_id: @banana.id}
        @menu_item_7 = @menu_item_ingredient_7_3.menu_item

        # Menu Item 8
        @menu_item_8 = FactoryGirl.create :menu_item, {title: 'Menu Item Number 8', price: 7.00, calories: 1525/3, fat: 50/3, carbohydrates: 209/3, protein: 56/3}
        @menu_item_ingredient_8_1 = FactoryGirl.create :menu_item_ingredient, {menu_item_id: @menu_item_8.id, food_id: @sweet_potato.id}
        @menu_item_ingredient_8_2 = FactoryGirl.create :menu_item_ingredient, {menu_item_id: @menu_item_8.id, food_id: @trout.id}
        @menu_item_ingredient_8_3 = FactoryGirl.create :menu_item_ingredient, {menu_item_id: @menu_item_8.id, food_id: @orange.id}
        @menu_item_8 = @menu_item_ingredient_8_3.menu_item

        # Menu Item 9
        @menu_item_9 = FactoryGirl.create :menu_item, {title: 'Menu Item Number 9', price: 3.00, calories: 1525/2, fat: 50/2, carbohydrates: 209/2, protein: 56/2}
        @menu_item_ingredient_9_1 = FactoryGirl.create :menu_item_ingredient, {menu_item_id: @menu_item_9.id, food_id: @carrot.id}
        @menu_item_ingredient_9_2 = FactoryGirl.create :menu_item_ingredient, {menu_item_id: @menu_item_9.id, food_id: @broccoli.id}
        @menu_item_ingredient_9_3 = FactoryGirl.create :menu_item_ingredient, {menu_item_id: @menu_item_9.id, food_id: @lentil.id}
        @menu_item_ingredient_9_4 = FactoryGirl.create :menu_item_ingredient, {menu_item_id: @menu_item_9.id, food_id: @pita_bread.id}
        @menu_item_9 = @menu_item_ingredient_9_4.menu_item

        @breakfast_gaurantee = FactoryGirl.create :food, {title: "breakfast_gaurantee", calories: 1144, fat: 38, carbohydrates: 157, protein: 42}
        @lunch_gaurantee = FactoryGirl.create :food, {title: "lunch_gaurantee", calories: 1144, fat: 38, carbohydrates: 157, protein: 42}
        @dinner_gaurantee = FactoryGirl.create :food, {title: "dinner_gaurantee", calories: 1525, fat: 50, carbohydrates: 209, protein: 56}
        @menu_item_10 = FactoryGirl.create :menu_item, {title: 'Menu Item Number 10', price: 3.00, calories: 1144/6, fat: 38/6, carbohydrates: 157/6, protein: 42/6}
        @menu_item_ingredient_10 = FactoryGirl.create :menu_item_ingredient, {menu_item_id: @menu_item_10.id, food_id: @breakfast_gaurantee.id}
        @menu_item_11 = FactoryGirl.create :menu_item, {title: 'Menu Item Number 11', price: 3.00, calories: 1144/6, fat: 38/6, carbohydrates: 157/6, protein: 42/6}
        @menu_item_ingredient_11 = FactoryGirl.create :menu_item_ingredient, {menu_item_id: @menu_item_11.id, food_id: @lunch_gaurantee.id}
        @menu_item_12 = FactoryGirl.create :menu_item, {title: 'Menu Item Number 12', price: 3.00, calories: 1525/6, fat: 50/6, carbohydrates: 209/6, protein: 56/6}
        @menu_item_ingredient_12 = FactoryGirl.create :menu_item_ingredient, {menu_item_id: @menu_item_12.id, food_id: @dinner_gaurantee.id}

        # INPUTS / CONSTRAINTS
        @daily_constraint_set_attrs = FactoryGirl.attributes_for :daily_constraint_set, user: @user
        @daily_constraint_set_attrs[:id] = 100
        @breakfast_attrs = FactoryGirl.attributes_for :meal_constraint_set_breakfast, 
          { user: @user, daily_constraint_set_id: @daily_constraint_set_attrs[:id]}
        @lunch_attrs = FactoryGirl.attributes_for :meal_constraint_set_lunch, 
         { user: @user, daily_constraint_set_id: @daily_constraint_set_attrs[:id]}
        @dinner_attrs = FactoryGirl.attributes_for :meal_constraint_set_dinner, 
         { user: @user, daily_constraint_set_id: @daily_constraint_set_attrs[:id]}
        @daily_constraint_set_attrs[:meal_constraint_sets] = [@breakfast_attrs, @lunch_attrs, @dinner_attrs]
        
        # Sources
        # @all_foods = FactoryGirl.create :source
        # @all_recipes = FactoryGirl.create :source
        @restaurant_1 = FactoryGirl.create :restaurant
        @restaurant_2 = FactoryGirl.create :restaurant
        @restaurant_3 = FactoryGirl.create :restaurant

        # Populate food sources
        # Food.where(type: '').each do |food| # (type: nil) returns 0 items, it doesn't work'
        #   FactoryGirl.create :source_item, {source: @all_foods, food: food}
        # end
        # Food.where(type: 'Recipe').each do |recipe|
        #   FactoryGirl.create :source_item, {source: @all_recipes, food: recipe}
        # end
        FactoryGirl.create :restaurant_join_menu_item, {restaurant_id: @restaurant_1.id, menu_item_id: @menu_item_1.id}
        FactoryGirl.create :restaurant_join_menu_item, {restaurant_id: @restaurant_1.id, menu_item_id: @menu_item_2.id}
        FactoryGirl.create :restaurant_join_menu_item, {restaurant_id: @restaurant_1.id, menu_item_id: @menu_item_3.id}
        FactoryGirl.create :restaurant_join_menu_item, {restaurant_id: @restaurant_2.id, menu_item_id: @menu_item_4.id}
        FactoryGirl.create :restaurant_join_menu_item, {restaurant_id: @restaurant_2.id, menu_item_id: @menu_item_5.id}
        FactoryGirl.create :restaurant_join_menu_item, {restaurant_id: @restaurant_2.id, menu_item_id: @menu_item_6.id}
        FactoryGirl.create :restaurant_join_menu_item, {restaurant_id: @restaurant_3.id, menu_item_id: @menu_item_7.id}
        FactoryGirl.create :restaurant_join_menu_item, {restaurant_id: @restaurant_3.id, menu_item_id: @menu_item_8.id}
        FactoryGirl.create :restaurant_join_menu_item, {restaurant_id: @restaurant_3.id, menu_item_id: @menu_item_9.id}
        FactoryGirl.create :restaurant_join_menu_item, {restaurant_id: @restaurant_1.id, menu_item_id: @menu_item_10.id}
        FactoryGirl.create :restaurant_join_menu_item, {restaurant_id: @restaurant_2.id, menu_item_id: @menu_item_11.id}
        FactoryGirl.create :restaurant_join_menu_item, {restaurant_id: @restaurant_3.id, menu_item_id: @menu_item_12.id}
      end

      context "For each meal, the food source is all foods & recipes; " do
        before(:each) do
          # INPUTS / FOOD DATA
          @included_foods_attrs = []
          @excluded_foods_attrs = []
          @included_food_amounts_attrs = [[]]
          @foods_by_sources_attrs = [{source_id: 1, # source_id == 0 => all foods and recipes (i.e. only excludes menu_items) 
                                        included_foods: @included_foods_attrs,
                                        excluded_foods: @excluded_foods_attrs,
                                        included_food_amounts: @included_food_amounts_attrs  
                                      }]
          @sources_by_meals_attrs = [{position: 1, foods_by_sources: @foods_by_sources_attrs},
                                    {position: 2, foods_by_sources: @foods_by_sources_attrs},
                                    {position: 3, foods_by_sources: @foods_by_sources_attrs}
                                    ]
          @meal_plan_input_attrs = { daily_constraint_set: @daily_constraint_set_attrs, sources_by_meals: @sources_by_meals_attrs }
          post :create, params: { user_id: @user.id, meal_plan_input: @meal_plan_input_attrs }
        end
          
        it "has the correct number of meals." do
          meal_plan_response = json_response[:meal_plan]
          expect(meal_plan_response[:meals].size).to eq 3
        end

        it "satisfies the nutrient constraints." do
          meal_plan_response = json_response[:meal_plan]
          expect(meal_plan_response[:calories].to_f).to be >= @daily_constraint_set_attrs[:min_calories]
          expect(meal_plan_response[:calories].to_f).to be <= @daily_constraint_set_attrs[:max_calories]
          expect(meal_plan_response[:fat].to_f).to be >= @daily_constraint_set_attrs[:min_fat]
          expect(meal_plan_response[:fat].to_f).to be <= @daily_constraint_set_attrs[:max_fat]
          expect(meal_plan_response[:carbohydrates].to_f).to be >= @daily_constraint_set_attrs[:min_carbohydrates]
          expect(meal_plan_response[:carbohydrates].to_f).to be <= @daily_constraint_set_attrs[:max_carbohydrates]
          expect(meal_plan_response[:protein].to_f).to be >= @daily_constraint_set_attrs[:min_protein]
          expect(meal_plan_response[:protein].to_f).to be <= @daily_constraint_set_attrs[:max_protein]
          expect(meal_plan_response[:meals][0][:calories].to_f).to be >= @breakfast_attrs[:min_calories]
          expect(meal_plan_response[:meals][0][:calories].to_f).to be <= @breakfast_attrs[:max_calories]
          expect(meal_plan_response[:meals][0][:fat].to_f).to be >= @breakfast_attrs[:min_fat]
          expect(meal_plan_response[:meals][0][:fat].to_f).to be <= @breakfast_attrs[:max_fat]
          expect(meal_plan_response[:meals][0][:carbohydrates].to_f).to be >= @breakfast_attrs[:min_carbohydrates]
          expect(meal_plan_response[:meals][0][:carbohydrates].to_f).to be <= @breakfast_attrs[:max_carbohydrates]
          expect(meal_plan_response[:meals][0][:protein].to_f).to be >= @breakfast_attrs[:min_protein]
          expect(meal_plan_response[:meals][0][:protein].to_f).to be <= @breakfast_attrs[:max_protein]
          expect(meal_plan_response[:meals][1][:calories].to_f).to be >= @lunch_attrs[:min_calories]
          expect(meal_plan_response[:meals][1][:calories].to_f).to be <= @lunch_attrs[:max_calories]
          expect(meal_plan_response[:meals][1][:fat].to_f).to be >= @lunch_attrs[:min_fat]
          expect(meal_plan_response[:meals][1][:fat].to_f).to be <= @lunch_attrs[:max_fat]
          expect(meal_plan_response[:meals][1][:carbohydrates].to_f).to be >= @lunch_attrs[:min_carbohydrates]
          expect(meal_plan_response[:meals][1][:carbohydrates].to_f).to be <= @lunch_attrs[:max_carbohydrates]
          expect(meal_plan_response[:meals][1][:protein].to_f).to be >= @lunch_attrs[:min_protein]
          expect(meal_plan_response[:meals][1][:protein].to_f).to be <= @lunch_attrs[:max_protein]
          expect(meal_plan_response[:meals][2][:calories].to_f).to be >= @dinner_attrs[:min_calories]
          expect(meal_plan_response[:meals][2][:calories].to_f).to be <= @dinner_attrs[:max_calories]
          expect(meal_plan_response[:meals][2][:fat].to_f).to be >= @dinner_attrs[:min_fat]
          expect(meal_plan_response[:meals][2][:fat].to_f).to be <= @dinner_attrs[:max_fat]
          expect(meal_plan_response[:meals][2][:carbohydrates].to_f).to be >= @dinner_attrs[:min_carbohydrates]
          expect(meal_plan_response[:meals][2][:carbohydrates].to_f).to be <= @dinner_attrs[:max_carbohydrates]
          expect(meal_plan_response[:meals][2][:protein].to_f).to be >= @dinner_attrs[:min_protein]
          expect(meal_plan_response[:meals][2][:protein].to_f).to be <= @dinner_attrs[:max_protein]
        end

        it { is_expected.to respond_with 201 }
      end


      context "Food sources are restaurant_1, restaurant_2, restaurant_3 in meal1, meal2, meal3 respectively: " do
        before(:each) do
          # INPUTS / FOOD DATA
          @included_foods_attrs = []
          @excluded_foods_attrs = []
          @included_food_amounts_attrs = [[]]
          @foods_by_sources_attrs_restaurant_1 = [{source_id: @restaurant_1.id, 
                                        included_foods: @included_foods_attrs,
                                        excluded_foods: @excluded_foods_attrs,
                                        included_food_amounts: @included_food_amounts_attrs  
                                      }]
          @foods_by_sources_attrs_restaurant_2 = [{source_id: @restaurant_2.id, 
                                        included_foods: @included_foods_attrs,
                                        excluded_foods: @excluded_foods_attrs,
                                        included_food_amounts: @included_food_amounts_attrs  
                                      }]
          @foods_by_sources_attrs_restaurant_3 = [{source_id: @restaurant_3.id, 
                                        included_foods: @included_foods_attrs,
                                        excluded_foods: @excluded_foods_attrs,
                                        included_food_amounts: @included_food_amounts_attrs  
                                      }]
          @sources_by_meals_attrs = [{position: 1, foods_by_sources: @foods_by_sources_attrs_restaurant_1},
                                    {position: 2, foods_by_sources: @foods_by_sources_attrs_restaurant_2},
                                    {position: 3, foods_by_sources: @foods_by_sources_attrs_restaurant_3}
                                    ]
          @meal_plan_input_attrs = { daily_constraint_set: @daily_constraint_set_attrs, sources_by_meals: @sources_by_meals_attrs }
          post :create, params: { user_id: @user.id, meal_plan_input: @meal_plan_input_attrs }
        end

        it "all breakfast items come from Restaurant 1" do
          breakfast_response = json_response[:meal_plan][:meals][0]
          expect((breakfast_response[:meal_items].pluck(:food).pluck(:id) - @restaurant_1.menu_items.pluck(:id)).length).to eq 0
        end

        it "all lunch items come from Restaurant 2" do
          lunch_response = json_response[:meal_plan][:meals][1]
          expect((lunch_response[:meal_items].pluck(:food).pluck(:id) - @restaurant_2.menu_items.pluck(:id)).length).to eq 0
        end

        it "all dinner items come from Restaurant 3" do
          dinner_response = json_response[:meal_plan][:meals][2]
          expect((dinner_response[:meal_items].pluck(:food).pluck(:id) - @restaurant_3.menu_items.pluck(:id)).length).to eq 0
        end

        it "satisfies the nutrient constraints." do
          meal_plan_response = json_response[:meal_plan]
          expect(meal_plan_response[:calories].to_f).to be >= @daily_constraint_set_attrs[:min_calories]
          expect(meal_plan_response[:calories].to_f).to be <= @daily_constraint_set_attrs[:max_calories]
          expect(meal_plan_response[:fat].to_f).to be >= @daily_constraint_set_attrs[:min_fat]
          expect(meal_plan_response[:fat].to_f).to be <= @daily_constraint_set_attrs[:max_fat]
          expect(meal_plan_response[:carbohydrates].to_f).to be >= @daily_constraint_set_attrs[:min_carbohydrates]
          expect(meal_plan_response[:carbohydrates].to_f).to be <= @daily_constraint_set_attrs[:max_carbohydrates]
          expect(meal_plan_response[:protein].to_f).to be >= @daily_constraint_set_attrs[:min_protein]
          expect(meal_plan_response[:protein].to_f).to be <= @daily_constraint_set_attrs[:max_protein]
          expect(meal_plan_response[:meals][0][:calories].to_f).to be >= @breakfast_attrs[:min_calories]
          expect(meal_plan_response[:meals][0][:calories].to_f).to be <= @breakfast_attrs[:max_calories]
          expect(meal_plan_response[:meals][0][:fat].to_f).to be >= @breakfast_attrs[:min_fat]
          expect(meal_plan_response[:meals][0][:fat].to_f).to be <= @breakfast_attrs[:max_fat]
          expect(meal_plan_response[:meals][0][:carbohydrates].to_f).to be >= @breakfast_attrs[:min_carbohydrates]
          expect(meal_plan_response[:meals][0][:carbohydrates].to_f).to be <= @breakfast_attrs[:max_carbohydrates]
          expect(meal_plan_response[:meals][0][:protein].to_f).to be >= @breakfast_attrs[:min_protein]
          expect(meal_plan_response[:meals][0][:protein].to_f).to be <= @breakfast_attrs[:max_protein]
          expect(meal_plan_response[:meals][1][:calories].to_f).to be >= @lunch_attrs[:min_calories]
          # expect(meal_plan_response[:meals][1][:calories].to_f).to be <= @lunch_attrs[:max_calories]
          expect(meal_plan_response[:meals][1][:fat].to_f).to be >= @lunch_attrs[:min_fat]
          expect(meal_plan_response[:meals][1][:fat].to_f).to be <= @lunch_attrs[:max_fat]
          expect(meal_plan_response[:meals][1][:carbohydrates].to_f).to be >= @lunch_attrs[:min_carbohydrates]
          expect(meal_plan_response[:meals][1][:carbohydrates].to_f).to be <= @lunch_attrs[:max_carbohydrates]
          expect(meal_plan_response[:meals][1][:protein].to_f).to be >= @lunch_attrs[:min_protein]
          expect(meal_plan_response[:meals][1][:protein].to_f).to be <= @lunch_attrs[:max_protein]
          expect(meal_plan_response[:meals][2][:calories].to_f).to be >= @dinner_attrs[:min_calories]
          expect(meal_plan_response[:meals][2][:calories].to_f).to be <= @dinner_attrs[:max_calories]
          expect(meal_plan_response[:meals][2][:fat].to_f).to be >= @dinner_attrs[:min_fat]
          expect(meal_plan_response[:meals][2][:fat].to_f).to be <= @dinner_attrs[:max_fat]
          expect(meal_plan_response[:meals][2][:carbohydrates].to_f).to be >= @dinner_attrs[:min_carbohydrates]
          expect(meal_plan_response[:meals][2][:carbohydrates].to_f).to be <= @dinner_attrs[:max_carbohydrates]
          expect(meal_plan_response[:meals][2][:protein].to_f).to be >= @dinner_attrs[:min_protein]
          expect(meal_plan_response[:meals][2][:protein].to_f).to be <= @dinner_attrs[:max_protein]
        end
      end

      context "Food sources are [restaurant_1, restaurant_2], [restaurant_2, restaurant_3], [all foods & recipes, restaurant_1] in meal1, meal2, meal3 respectively: " do
        before(:each) do
          # INPUTS / FOOD DATA
          @included_foods_attrs = []
          @excluded_foods_attrs = []
          @included_food_amounts_attrs = [[]]
          @foods_by_sources_attrs_restaurant_1 = [{ 
                                                    source_id: @restaurant_1.id,
                                                    included_foods: @included_foods_attrs,
                                                    excluded_foods: @excluded_foods_attrs,
                                                    included_food_amounts: @included_food_amounts_attrs  
                                                  },
                                                  {
                                                    source_id: @restaurant_2.id,
                                                    included_foods: @included_foods_attrs,
                                                    excluded_foods: @excluded_foods_attrs,
                                                    included_food_amounts: @included_food_amounts_attrs  
                                                  }]
          @foods_by_sources_attrs_restaurant_2 = [{
                                                    source_id:@restaurant_2.id,
                                                    included_foods: @included_foods_attrs,
                                                    excluded_foods: @excluded_foods_attrs,
                                                    included_food_amounts: @included_food_amounts_attrs  
                                                  },
                                                  {
                                                    source_id:@restaurant_3.id,
                                                    included_foods: @included_foods_attrs,
                                                    excluded_foods: @excluded_foods_attrs,
                                                    included_food_amounts: @included_food_amounts_attrs  
                                                  }]
          @foods_by_sources_attrs_restaurant_3 = [{
                                                    source_id: 1,
                                                    included_foods: @included_foods_attrs,
                                                    excluded_foods: @excluded_foods_attrs,
                                                    included_food_amounts: @included_food_amounts_attrs  
                                                  },
                                                  { 
                                                    source_id: @restaurant_1.id,
                                                    included_foods: @included_foods_attrs,
                                                    excluded_foods: @excluded_foods_attrs,
                                                    included_food_amounts: @included_food_amounts_attrs  
                                                  }]
          @sources_by_meals_attrs = [{position: 1, foods_by_sources: @foods_by_sources_attrs_restaurant_1},
                                    {position: 2, foods_by_sources: @foods_by_sources_attrs_restaurant_2},
                                    {position: 3, foods_by_sources: @foods_by_sources_attrs_restaurant_3}
                                    ]
          @meal_plan_input_attrs = { daily_constraint_set: @daily_constraint_set_attrs, sources_by_meals: @sources_by_meals_attrs }
          post :create, params: { user_id: @user.id, meal_plan_input: @meal_plan_input_attrs }
        end

        it "all breakfast items come from Restaurant 1 or Restaurant 2, exclusively" do
          breakfast_response = json_response[:meal_plan][:meals][0]
          expect(breakfast_response[:meal_items].length).to be > 0
          expect(
            (breakfast_response[:meal_items].pluck(:food).pluck(:id) - @restaurant_1.menu_items.pluck(:id)).length == 0 ||
            (breakfast_response[:meal_items].pluck(:food).pluck(:id) - @restaurant_2.menu_items.pluck(:id)).length == 0
            ).to be true
          expect(
            (breakfast_response[:meal_items].pluck(:food).pluck(:id) - @restaurant_1.menu_items.pluck(:id)).length > 0 ||
            (breakfast_response[:meal_items].pluck(:food).pluck(:id) - @restaurant_2.menu_items.pluck(:id)).length > 0
            ).to be true
        end

        it "all lunch items come from Restaurant 2 or Restaurant 3, exclusively" do
          lunch_response = json_response[:meal_plan][:meals][1]
          expect(lunch_response[:meal_items].length).to be > 0
          expect(
            (lunch_response[:meal_items].pluck(:food).pluck(:id) - @restaurant_2.menu_items.pluck(:id)).length == 0 ||
            (lunch_response[:meal_items].pluck(:food).pluck(:id) - @restaurant_3.menu_items.pluck(:id)).length == 0
            ).to be true
          expect(
            (lunch_response[:meal_items].pluck(:food).pluck(:id) - @restaurant_2.menu_items.pluck(:id)).length > 0 ||
            (lunch_response[:meal_items].pluck(:food).pluck(:id) - @restaurant_3.menu_items.pluck(:id)).length > 0
            ).to be true
        end

        it "all dinner items come from Restaurant 1 or (all foods & recipes), exclusively" do
          dinner_response = json_response[:meal_plan][:meals][2]
          expect(dinner_response[:meal_items].length).to be > 0
          expect(
            (dinner_response[:meal_items].pluck(:food).pluck(:id) - @restaurant_1.menu_items.pluck(:id)).length == 0 ||
            (dinner_response[:meal_items].pluck(:food).pluck(:id) - Food.all.pluck(:id)).length == 0
            ).to be true
          expect(
            (dinner_response[:meal_items].pluck(:food).pluck(:id) - @restaurant_1.menu_items.pluck(:id)).length > 0 ||
            (dinner_response[:meal_items].pluck(:food).pluck(:id) - Food.all.pluck(:id)).length > 0
            ).to be true
        end

        it "satisfies the nutrient constraints." do
          meal_plan_response = json_response[:meal_plan]
          expect(meal_plan_response[:calories].to_f).to be >= @daily_constraint_set_attrs[:min_calories]
          expect(meal_plan_response[:calories].to_f).to be <= @daily_constraint_set_attrs[:max_calories]
          expect(meal_plan_response[:fat].to_f).to be >= @daily_constraint_set_attrs[:min_fat]
          expect(meal_plan_response[:fat].to_f).to be <= @daily_constraint_set_attrs[:max_fat]
          expect(meal_plan_response[:carbohydrates].to_f).to be >= @daily_constraint_set_attrs[:min_carbohydrates]
          expect(meal_plan_response[:carbohydrates].to_f).to be <= @daily_constraint_set_attrs[:max_carbohydrates]
          expect(meal_plan_response[:protein].to_f).to be >= @daily_constraint_set_attrs[:min_protein]
          expect(meal_plan_response[:protein].to_f).to be <= @daily_constraint_set_attrs[:max_protein]
          expect(meal_plan_response[:meals][0][:calories].to_f).to be >= @breakfast_attrs[:min_calories]
          #expect(meal_plan_response[:meals][0][:calories].to_f).to be <= @breakfast_attrs[:max_calories]
          expect(meal_plan_response[:meals][0][:fat].to_f).to be >= @breakfast_attrs[:min_fat]
          expect(meal_plan_response[:meals][0][:fat].to_f).to be <= @breakfast_attrs[:max_fat]
          expect(meal_plan_response[:meals][0][:carbohydrates].to_f).to be >= @breakfast_attrs[:min_carbohydrates]
          expect(meal_plan_response[:meals][0][:carbohydrates].to_f).to be <= @breakfast_attrs[:max_carbohydrates]
          expect(meal_plan_response[:meals][0][:protein].to_f).to be >= @breakfast_attrs[:min_protein]
          expect(meal_plan_response[:meals][0][:protein].to_f).to be <= @breakfast_attrs[:max_protein]
          expect(meal_plan_response[:meals][1][:calories].to_f).to be >= @lunch_attrs[:min_calories]
          expect(meal_plan_response[:meals][1][:calories].to_f).to be <= @lunch_attrs[:max_calories]
          expect(meal_plan_response[:meals][1][:fat].to_f).to be >= @lunch_attrs[:min_fat]
          expect(meal_plan_response[:meals][1][:fat].to_f).to be <= @lunch_attrs[:max_fat]
          expect(meal_plan_response[:meals][1][:carbohydrates].to_f).to be >= @lunch_attrs[:min_carbohydrates]
          expect(meal_plan_response[:meals][1][:carbohydrates].to_f).to be <= @lunch_attrs[:max_carbohydrates]
          expect(meal_plan_response[:meals][1][:protein].to_f).to be >= @lunch_attrs[:min_protein]
          expect(meal_plan_response[:meals][1][:protein].to_f).to be <= @lunch_attrs[:max_protein]
          expect(meal_plan_response[:meals][2][:calories].to_f).to be >= @dinner_attrs[:min_calories]
          expect(meal_plan_response[:meals][2][:calories].to_f).to be <= @dinner_attrs[:max_calories]
          expect(meal_plan_response[:meals][2][:fat].to_f).to be >= @dinner_attrs[:min_fat]
          expect(meal_plan_response[:meals][2][:fat].to_f).to be <= @dinner_attrs[:max_fat]
          expect(meal_plan_response[:meals][2][:carbohydrates].to_f).to be >= @dinner_attrs[:min_carbohydrates]
          expect(meal_plan_response[:meals][2][:carbohydrates].to_f).to be <= @dinner_attrs[:max_carbohydrates]
          expect(meal_plan_response[:meals][2][:protein].to_f).to be >= @dinner_attrs[:min_protein]
          expect(meal_plan_response[:meals][2][:protein].to_f).to be <= @dinner_attrs[:max_protein]
        end
      end

      context "5 Meals: Food sources are all foods and recipes for each" do
        before(:each) do
          # INPUTS / FOOD DATA
          @five_meals_daily_constraint_set_attrs = FactoryGirl.attributes_for :five_meals_daily_constraint_set, user: @user
          @five_meals_meal_attrs = FactoryGirl.attributes_for :five_meals_constraint_set, 
            { user: @user, daily_constraint_set_id: @five_meals_daily_constraint_set_attrs[:id]}
          @daily_constraint_set_attrs[:meal_constraint_sets] = [@five_meals_meal_attrs,
                                                                  @five_meals_meal_attrs,
                                                                  @five_meals_meal_attrs,
                                                                  @five_meals_meal_attrs,
                                                                  @five_meals_meal_attrs]
          @included_foods_attrs = []
          @excluded_foods_attrs = []
          @included_food_amounts_attrs = [[]]
          @foods_by_sources = [{source_id: 1, 
                                included_foods: @included_foods_attrs,
                                excluded_foods: @excluded_foods_attrs,
                                included_food_amounts: @included_food_amounts_attrs  
                              }]
          @sources_by_meals_attrs = [{position: 1, foods_by_sources: @foods_by_sources},
                                    {position: 2, foods_by_sources: @foods_by_sources},
                                    {position: 3, foods_by_sources: @foods_by_sources},
                                    {position: 4, foods_by_sources: @foods_by_sources},
                                    {position: 5, foods_by_sources: @foods_by_sources}
                                    ]
          @meal_plan_input_attrs = { daily_constraint_set: @daily_constraint_set_attrs, sources_by_meals: @sources_by_meals_attrs }
          post :create, params: { user_id: @user.id, meal_plan_input: @meal_plan_input_attrs }
        end

        it "satisfies the nutrient constraints." do
          meal_plan_response = json_response[:meal_plan]
          expect(meal_plan_response[:calories].to_f).to be >= @daily_constraint_set_attrs[:min_calories]
          expect(meal_plan_response[:calories].to_f).to be <= @daily_constraint_set_attrs[:max_calories]
          expect(meal_plan_response[:fat].to_f).to be >= @daily_constraint_set_attrs[:min_fat]
          expect(meal_plan_response[:fat].to_f).to be <= @daily_constraint_set_attrs[:max_fat]
          expect(meal_plan_response[:carbohydrates].to_f).to be >= @daily_constraint_set_attrs[:min_carbohydrates]
          expect(meal_plan_response[:carbohydrates].to_f).to be <= @daily_constraint_set_attrs[:max_carbohydrates]
          expect(meal_plan_response[:protein].to_f).to be >= @daily_constraint_set_attrs[:min_protein]
          expect(meal_plan_response[:protein].to_f).to be <= @daily_constraint_set_attrs[:max_protein]
          expect(meal_plan_response[:meals][0][:calories].to_f).to be >= @five_meals_meal_attrs[:min_calories]
          expect(meal_plan_response[:meals][0][:calories].to_f).to be <= @five_meals_meal_attrs[:max_calories]
          expect(meal_plan_response[:meals][0][:fat].to_f).to be >= @five_meals_meal_attrs[:min_fat]
          expect(meal_plan_response[:meals][0][:fat].to_f).to be <= @five_meals_meal_attrs[:max_fat]
          expect(meal_plan_response[:meals][0][:carbohydrates].to_f).to be >= @five_meals_meal_attrs[:min_carbohydrates]
          expect(meal_plan_response[:meals][0][:carbohydrates].to_f).to be <= @five_meals_meal_attrs[:max_carbohydrates]
          expect(meal_plan_response[:meals][0][:protein].to_f).to be >= @five_meals_meal_attrs[:min_protein]
          expect(meal_plan_response[:meals][0][:protein].to_f).to be <= @five_meals_meal_attrs[:max_protein]
          expect(meal_plan_response[:meals][1][:calories].to_f).to be >= @five_meals_meal_attrs[:min_calories]
          expect(meal_plan_response[:meals][1][:calories].to_f).to be <= @five_meals_meal_attrs[:max_calories]
          expect(meal_plan_response[:meals][1][:fat].to_f).to be >= @five_meals_meal_attrs[:min_fat]
          expect(meal_plan_response[:meals][1][:fat].to_f).to be <= @five_meals_meal_attrs[:max_fat]
          expect(meal_plan_response[:meals][1][:carbohydrates].to_f).to be >= @five_meals_meal_attrs[:min_carbohydrates]
          expect(meal_plan_response[:meals][1][:carbohydrates].to_f).to be <= @five_meals_meal_attrs[:max_carbohydrates]
          expect(meal_plan_response[:meals][1][:protein].to_f).to be >= @five_meals_meal_attrs[:min_protein]
          expect(meal_plan_response[:meals][1][:protein].to_f).to be <= @five_meals_meal_attrs[:max_protein]
          expect(meal_plan_response[:meals][2][:calories].to_f).to be >= @five_meals_meal_attrs[:min_calories]
          expect(meal_plan_response[:meals][2][:calories].to_f).to be <= @five_meals_meal_attrs[:max_calories]
          expect(meal_plan_response[:meals][2][:fat].to_f).to be >= @five_meals_meal_attrs[:min_fat]
          expect(meal_plan_response[:meals][2][:fat].to_f).to be <= @five_meals_meal_attrs[:max_fat]
          expect(meal_plan_response[:meals][2][:carbohydrates].to_f).to be >= @five_meals_meal_attrs[:min_carbohydrates]
          expect(meal_plan_response[:meals][2][:carbohydrates].to_f).to be <= @five_meals_meal_attrs[:max_carbohydrates]
          expect(meal_plan_response[:meals][2][:protein].to_f).to be >= @five_meals_meal_attrs[:min_protein]
          expect(meal_plan_response[:meals][2][:protein].to_f).to be <= @five_meals_meal_attrs[:max_protein]
          expect(meal_plan_response[:meals][3][:calories].to_f).to be >= @five_meals_meal_attrs[:min_calories]
          expect(meal_plan_response[:meals][3][:calories].to_f).to be <= @five_meals_meal_attrs[:max_calories]
          expect(meal_plan_response[:meals][3][:fat].to_f).to be >= @five_meals_meal_attrs[:min_fat]
          expect(meal_plan_response[:meals][3][:fat].to_f).to be <= @five_meals_meal_attrs[:max_fat]
          expect(meal_plan_response[:meals][3][:carbohydrates].to_f).to be >= @five_meals_meal_attrs[:min_carbohydrates]
          expect(meal_plan_response[:meals][3][:carbohydrates].to_f).to be <= @five_meals_meal_attrs[:max_carbohydrates]
          expect(meal_plan_response[:meals][3][:protein].to_f).to be >= @five_meals_meal_attrs[:min_protein]
          expect(meal_plan_response[:meals][3][:protein].to_f).to be <= @five_meals_meal_attrs[:max_protein]
          expect(meal_plan_response[:meals][4][:calories].to_f).to be >= @five_meals_meal_attrs[:min_calories]
          expect(meal_plan_response[:meals][4][:calories].to_f).to be <= @five_meals_meal_attrs[:max_calories]
          expect(meal_plan_response[:meals][4][:fat].to_f).to be >= @five_meals_meal_attrs[:min_fat]
          expect(meal_plan_response[:meals][4][:fat].to_f).to be <= @five_meals_meal_attrs[:max_fat]
          expect(meal_plan_response[:meals][4][:carbohydrates].to_f).to be >= @five_meals_meal_attrs[:min_carbohydrates]
          expect(meal_plan_response[:meals][4][:carbohydrates].to_f).to be <= @five_meals_meal_attrs[:max_carbohydrates]
          expect(meal_plan_response[:meals][4][:protein].to_f).to be >= @five_meals_meal_attrs[:min_protein]
          expect(meal_plan_response[:meals][4][:protein].to_f).to be <= @five_meals_meal_attrs[:max_protein]
        end
      end

      context "One meal with two fixed meal items" do
        before(:each) do
          # Foods
          # @cucumber = FactoryGirl.create :food, {title: "cucumber", calories: 15, fat: 0.1, carbohydrates: 3.6, protein: 0.7}
          # @breakfast_gaurantee = FactoryGirl.create :food, {title: "breakfast_gaurantee", calories: 1144, fat: 38, carbohydrates: 157, protein: 42}
          @one_meal_daily_constraint_set_attrs = FactoryGirl.attributes_for :one_meal_daily_constraint_set, user: @user
          @one_meal_daily_constraint_set_attrs[:id] = 100
          @breakfast_attrs = FactoryGirl.attributes_for :meal_constraint_set_breakfast, 
            { user: @user, daily_constraint_set_id: @one_meal_daily_constraint_set_attrs[:id]}
          @one_meal_daily_constraint_set_attrs[:meal_constraint_sets] = [@breakfast_attrs]
          @included_foods_attrs = [{food_id: @cucumber.id}, {food_id: @breakfast_gaurantee.id}]
          @included_food_amounts_attrs = [{food_id: @cucumber.id, amount: 2}, {food_id: @breakfast_gaurantee.id, amount: 1}]
          @excluded_foods_attrs = []
          @foods_by_sources_attrs = [{source_id: 1, 
                                      included_foods: @included_foods_attrs,
                                      excluded_foods: @excluded_foods_attrs,
                                      included_food_amounts: @included_food_amounts_attrs  
                                      }]
          @sources_by_meals_attrs = [{position: 1, foods_by_sources: @foods_by_sources_attrs}
                                    ]
          @meal_plan_input_attrs = { daily_constraint_set: @one_meal_daily_constraint_set_attrs, sources_by_meals: @sources_by_meals_attrs }
          post :create, params: { user_id: @user.id, meal_plan_input: @meal_plan_input_attrs }
        end

        it "has the correct number of meals and amounts for each meal item." do
          meal_plan_response = json_response[:meal_plan]
          expect(meal_plan_response[:meals].size).to eq 1
          expect(meal_plan_response[:meals][0][:meal_items].size).to eq 2
          expect(meal_plan_response[:meals][0][:meal_items][0][:amount].to_i).to eq 2
          expect(meal_plan_response[:meals][0][:meal_items][1][:amount].to_i).to eq 1
        end
      end

      context "Three meals, each has two fixed meal items" do
        before(:each) do
          # Foods
          # @cucumber = FactoryGirl.create :food, {title: "cucumber", calories: 15, fat: 0.1, carbohydrates: 3.6, protein: 0.7}
          # @breakfast_gaurantee = FactoryGirl.create :food, {title: "breakfast_gaurantee", calories: 1144, fat: 38, carbohydrates: 157, protein: 42}
          # @lunch_gaurantee = FactoryGirl.create :food, {title: "lunch_gaurantee", calories: 1144, fat: 38, carbohydrates: 157, protein: 42}
          # @dinner_gaurantee = FactoryGirl.create :food, {title: "dinner_gaurantee", calories: 1525, fat: 50, carbohydrates: 209, protein: 56}
          @included_foods_breakfast_attrs = [{food_id: @cucumber.id}, {food_id: @breakfast_gaurantee.id}]
          @included_foods_lunch_attrs = [{food_id: @cucumber.id}, {food_id: @lunch_gaurantee.id}]
          @included_foods_dinner_attrs = [{food_id: @dinner_gaurantee.id}, {food_id: @cucumber.id}]
          @excluded_foods_attrs = []
          @included_food_amounts_breakfast_attrs = [{food_id: @cucumber.id, amount: 2}, {food_id: @breakfast_gaurantee.id, amount: 1},]
          @included_food_amounts_lunch_attrs = [{food_id: @cucumber.id, amount: 1}, {food_id: @lunch_gaurantee.id, amount: 1}]
          @included_food_amounts_dinner_attrs = [{food_id: @dinner_gaurantee.id, amount: 1}, {food_id: @cucumber.id, amount: 3}]
          @foods_by_sources_breakfast_attrs = [{source_id: 1, 
                                                included_foods: @included_foods_breakfast_attrs,
                                                excluded_foods: @excluded_foods_attrs,
                                                included_food_amounts: @included_food_amounts_breakfast_attrs  
                                              }]
          @foods_by_sources_lunch_attrs = [{source_id: 1, 
                                            included_foods: @included_foods_lunch_attrs,
                                            excluded_foods: @excluded_foods_attrs,
                                            included_food_amounts: @included_food_amounts_lunch_attrs  
                                          }]
          @foods_by_sources_dinner_attrs = [{source_id: 1, 
                                              included_foods: @included_foods_dinner_attrs,
                                              excluded_foods: @excluded_foods_attrs,
                                              included_food_amounts: @included_food_amounts_dinner_attrs  
                                            }]
          @sources_by_meals_attrs = [{position: 1, foods_by_sources: @foods_by_sources_breakfast_attrs},
                                     {position: 2, foods_by_sources: @foods_by_sources_lunch_attrs},
                                     {position: 3, foods_by_sources: @foods_by_sources_dinner_attrs}
                                    ]
          @meal_plan_input_attrs = { daily_constraint_set: @daily_constraint_set_attrs, sources_by_meals: @sources_by_meals_attrs }
          post :create, params: { user_id: @user.id, meal_plan_input: @meal_plan_input_attrs }
        end

        it "has the correct number of meals and amounts for each meal item." do
          meal_plan_response = json_response[:meal_plan]
          expect(meal_plan_response[:meals].size).to eq 3
          expect(meal_plan_response[:meals][0][:meal_items].size).to eq 2
          expect(meal_plan_response[:meals][1][:meal_items].size).to eq 2
          expect(meal_plan_response[:meals][2][:meal_items].size).to eq 2
          expect(meal_plan_response[:meals][0][:meal_items][0][:amount].to_i).to eq 2
          expect(meal_plan_response[:meals][0][:meal_items][1][:amount].to_i).to eq 1
          expect(meal_plan_response[:meals][1][:meal_items][0][:amount].to_i).to eq 1
          expect(meal_plan_response[:meals][1][:meal_items][1][:amount].to_i).to eq 1
          expect(meal_plan_response[:meals][2][:meal_items][0][:amount].to_i).to eq 1
          expect(meal_plan_response[:meals][2][:meal_items][1][:amount].to_i).to eq 3
        end
      end

      context "Three meals, only the second has (2) fixed meal items" do
        before(:each) do
          # Foods
          # @cucumber = FactoryGirl.create :food, {title: "cucumber", calories: 15, fat: 0.1, carbohydrates: 3.6, protein: 0.7}
          # @breakfast_gaurantee = FactoryGirl.create :food, {title: "breakfast_gaurantee", calories: 1144, fat: 38, carbohydrates: 157, protein: 42}
          # @lunch_gaurantee = FactoryGirl.create :food, {title: "lunch_gaurantee", calories: 1144, fat: 38, carbohydrates: 157, protein: 42}
          # @dinner_gaurantee = FactoryGirl.create :food, {title: "dinner_gaurantee", calories: 1525, fat: 50, carbohydrates: 209, protein: 56}
          @included_foods = []
          @included_foods_lunch_attrs = [{food_id: @cucumber.id}, {food_id: @lunch_gaurantee.id}]
          @excluded_foods_attrs = []
          @included_food_amounts_attrs = []
          @included_food_amounts_lunch_attrs = [{food_id: @cucumber.id, amount: 2}, {food_id: @lunch_gaurantee.id, amount: 1}]
          @foods_by_sources_breakfast_attrs = [{source_id: 1, 
                                                included_foods: @included_foods,
                                                excluded_foods: @excluded_foods_attrs,
                                                included_food_amounts: @included_food_amounts_attrs  
                                              }]
          @foods_by_sources_lunch_attrs = [{source_id: 1, 
                                            included_foods: @included_foods_lunch_attrs,
                                            excluded_foods: @excluded_foods_attrs,
                                            included_food_amounts: @included_food_amounts_lunch_attrs  
                                          }]
          @foods_by_sources_dinner_attrs = [{source_id: 1, 
                                              included_foods: @included_foods,
                                              excluded_foods: @excluded_foods_attrs,
                                              included_food_amounts: @included_food_amounts_attrs  
                                            }]
          @sources_by_meals_attrs = [{position: 1, foods_by_sources: @foods_by_sources_breakfast_attrs},
                                     {position: 2, foods_by_sources: @foods_by_sources_lunch_attrs},
                                     {position: 3, foods_by_sources: @foods_by_sources_dinner_attrs}
                                    ]
          @meal_plan_input_attrs = { daily_constraint_set: @daily_constraint_set_attrs, sources_by_meals: @sources_by_meals_attrs }
          post :create, params: { user_id: @user.id, meal_plan_input: @meal_plan_input_attrs }
        end

        it "has the correct number of meals and amounts for each meal item." do
          meal_plan_response = json_response[:meal_plan]
          expect(meal_plan_response[:meals].size).to eq 3
          expect(meal_plan_response[:meals][1][:meal_items].size).to eq 2
          expect(meal_plan_response[:meals][1][:meal_items][0][:amount].to_i).to eq 2
          expect(meal_plan_response[:meals][1][:meal_items][1][:amount].to_i).to eq 1
        end
      end

      context "Three meals, each has two fixed meal items, but additional items are included" do
        before(:each) do
          @included_foods_breakfast_attrs = [{food_id: @cucumber.id}, 
                                            {food_id: @breakfast_gaurantee.id}, 
                                            {food_id: @kale.id}]
          @included_foods_lunch_attrs = [{food_id: @cucumber.id}, 
                                         {food_id: @lunch_gaurantee.id}, 
                                         {food_id: @recipe_9.id}, 
                                         {food_id: @breakfast_gaurantee.id}]
          @included_foods_dinner_attrs = [{food_id: @dinner_gaurantee.id}, 
                                          {food_id: @avocado.id},
                                          {food_id: @blueberry.id},
                                          {food_id: @cucumber.id}]
          @excluded_foods_attrs = []
          @included_food_amounts_breakfast_attrs = [{food_id: @cucumber.id, amount: 2}, {food_id: @breakfast_gaurantee.id, amount: 1},]
          @included_food_amounts_lunch_attrs = [{food_id: @cucumber.id, amount: 1}, {food_id: @lunch_gaurantee.id, amount: 1}]
          @included_food_amounts_dinner_attrs = [{food_id: @dinner_gaurantee.id, amount: 1}, {food_id: @cucumber.id, amount: 3}]
          @foods_by_sources_breakfast_attrs = [{source_id: 1, 
                                                included_foods: @included_foods_breakfast_attrs,
                                                excluded_foods: @excluded_foods_attrs,
                                                included_food_amounts: @included_food_amounts_breakfast_attrs  
                                              }]
          @foods_by_sources_lunch_attrs = [{source_id: 1, 
                                            included_foods: @included_foods_lunch_attrs,
                                            excluded_foods: @excluded_foods_attrs,
                                            included_food_amounts: @included_food_amounts_lunch_attrs  
                                          }]
          @foods_by_sources_dinner_attrs = [{source_id: 1, 
                                              included_foods: @included_foods_dinner_attrs,
                                              excluded_foods: @excluded_foods_attrs,
                                              included_food_amounts: @included_food_amounts_dinner_attrs  
                                            }]
          @sources_by_meals_attrs = [{position: 1, foods_by_sources: @foods_by_sources_breakfast_attrs},
                                     {position: 2, foods_by_sources: @foods_by_sources_lunch_attrs},
                                     {position: 3, foods_by_sources: @foods_by_sources_dinner_attrs}
                                    ]
          @meal_plan_input_attrs = { daily_constraint_set: @daily_constraint_set_attrs, sources_by_meals: @sources_by_meals_attrs }
          post :create, params: { user_id: @user.id, meal_plan_input: @meal_plan_input_attrs }
        end

        it "has the correct number of meals and amounts for each meal item." do
          meal_plan_response = json_response[:meal_plan]
          expect(meal_plan_response[:meals].size).to eq 3
          expect(meal_plan_response[:meals][0][:meal_items].size).to eq 2
          expect(meal_plan_response[:meals][1][:meal_items].size).to eq 2
          expect(meal_plan_response[:meals][2][:meal_items].size).to eq 2
          expect(meal_plan_response[:meals][0][:meal_items][0][:amount].to_i).to eq 2
          expect(meal_plan_response[:meals][0][:meal_items][1][:amount].to_i).to eq 1
          expect(meal_plan_response[:meals][1][:meal_items][0][:amount].to_i).to eq 1
          expect(meal_plan_response[:meals][1][:meal_items][1][:amount].to_i).to eq 1
          expect(meal_plan_response[:meals][2][:meal_items][0][:amount].to_i).to eq 1
          expect(meal_plan_response[:meals][2][:meal_items][1][:amount].to_i).to eq 3
        end
      end

    end
  end
end
        