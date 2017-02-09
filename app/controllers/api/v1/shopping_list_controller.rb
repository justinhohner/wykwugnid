class API::V1::ShoppingListController < ApplicationController
  before_action :authenticate_with_token!
  respond_to :json

  def show
    render json: current_user.shopping_list, status: 200, location: [:api, current_user, @pantry]
  end

  def update
    @shopping_list = current_user.shopping_list
    save_shopping_list_items(@shopping_list.id, shopping_list_items_params) unless shopping_list_items_params.empty?
    if @shopping_list.reload
      render json: @shopping_list, status: 200, location: [:api, current_user, @shopping_list]
    else
      render json: { errors: @shopping_list.errors }, status: 422
    end
  end

  def add_food
    @shopping_list = current_user.shopping_list
    save_food(@shopping_list.id, food_params) unless food_params.empty?
    if @shopping_list.reload
      render json: @shopping_list, status: 200, location: [:api, current_user, @shopping_list]
    else
      render json: { errors: @shopping_list.errors }, status: 422
    end
  end

  def add_recipe
    @shopping_list = current_user.shopping_list
    save_recipe(@shopping_list.id, recipe_params) unless recipe_params.empty?
    if @shopping_list.reload
      render json: @shopping_list, status: 200, location: [:api, current_user, @shopping_list]
    else
      render json: { errors: @shopping_list.errors }, status: 422
    end
  end

  def add_meal
    @shopping_list = current_user.shopping_list
    save_meal(@shopping_list.id, meal_params) unless meal_params.empty?
    if @shopping_list.reload
      render json: @shopping_list, status: 200, location: [:api, current_user, @shopping_list]
    else
      render json: { errors: @shopping_list.errors }, status: 422
    end
  end

  def add_meal_plan
    @shopping_list = current_user.shopping_list
    save_meal_plan(@shopping_list.id, meal_plan_params) unless meal_plan_params.empty?
    if @shopping_list.reload
      render json: @shopping_list, status: 200, location: [:api, current_user, @shopping_list]
    else
      render json: { errors: @shopping_list.errors }, status: 422
    end
  end

  private

  def shopping_list_items_params
    params.require(:shopping_list).permit( shopping_list_items: [:id, :amount, :food_id, :_destroy] )
  end

  def food_params
    params.require(:shopping_list).permit(:amount, food: :id )
  end

  def recipe_params
    params.require(:shopping_list).permit( recipe: :id)
  end

  def meal_params
    params.require(:shopping_list).permit( meal: :id)
  end

  def meal_plan_params
     params.require(:shopping_list).permit( meal_plan: :id)
  end

  def save_shopping_list_items(shopping_list_id, shopping_list_items_params)
    shopping_list_items = shopping_list_items_params[:shopping_list_items]
    shopping_list_items.each do |new_shopping_list_item|
      if ( (new_shopping_list_item_id = new_shopping_list_item[:id]) &&  (new_shopping_list_item[:id] != "") )
        old_shopping_list_item = ShoppingListItem.find(new_shopping_list_item_id)
        if (new_shopping_list_item[:_destroy] && (new_shopping_list_item[:_destroy] == 1) )
          old_shopping_list_item.destroy 
        else
          # old_shopping_list_item.amount = new_shopping_list_item[:amount] if new_shopping_list_item[:amount].present?
          # old_shopping_list_item.food_id = new_shopping_list_item[:food_id] if new_shopping_list_item[:food_id].present?
          # old_shopping_list_item.save
          old_shopping_list_item.update(amount: new_shopping_list_item[:amount], food_id: new_shopping_list_item[:food_id])
        end
      else
        ShoppingListItem.create(amount: new_shopping_list_item[:amount], shopping_list_id: shopping_list_id, food_id: new_shopping_list_item[:food_id])
      end
    end
  end

  def save_food(shopping_list_id, food_params)
    ShoppingListItem.create(amount: food_params[:amount], shopping_list_id: shopping_list_id, food_id: food_params[:food][:id])
  end

  def save_recipe(shopping_list_id, recipe_params)
    recipe = Recipe.find(recipe_params[:recipe][:id])
    recipe.ingredients.each do |ingredient|
      ShoppingListItem.create(amount: ingredient.amount, shopping_list_id: shopping_list_id, food_id: ingredient.food_id)
    end
  end

  def save_meal(shopping_list_id, meal_params)
    meal = Meal.find(meal_params[:meal][:id])
    meal.meal_items.each do |meal_item|
      ShoppingListItem.create(amount: meal_item.amount, shopping_list_id: shopping_list_id, food_id: meal_item.food_id)
    end
  end

  def save_meal_plan(shopping_list_id, meal_plan_params)
    meal_plan = MealPlan.find(meal_plan_params[:meal_plan][:id])
    meal_plan.meals.each do |meal|
      meal.meal_items.each do |meal_item|
        ShoppingListItem.create(amount: meal_item.amount, shopping_list_id: shopping_list_id, food_id: meal_item.food_id)
      end
    end
  end

end
