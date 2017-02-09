class API::V1::MealsController < ApplicationController
  before_action :authenticate_with_token!, only: [:create, :update, :destroy]
  respond_to :json

  def index
    respond_with Meal.search(params)
    # Change to this when I need pagination
    # @meals =  Meal.search(params).page(params[:page]).per(params[:per_page])
    # render json: @meals, meta: pagination(@meals, params[:per_page])
  end

  def show
    respond_with Meal.find(params[:id]), status: 200
  end

  def create
    @meal = current_user.meals.build(meal_params)
    if @meal.save
      save_meal_items(@meal.id, meal_items_params) unless meal_items_params.empty?
      @meal.reload
      render json: @meal, status: 201, location: [:api, @meal]
    else
      render json: { errors: @meal.errors }, status: 422
    end
  end

  def update
    @meal = current_user.meals.find(params[:id])
    if @meal.update(meal_params)
      save_meal_items(@meal.id, meal_items_params) unless meal_items_params.empty?
      @meal.reload
      render json: @meal, status: 200, location: [:api, @meal]
    else
      render json: { errors: @meal.errors }, status: 422
    end
  end

  def destroy
    @meal = current_user.meals.find(params[:id])
    @meal.destroy
    head 204
  end

  private

  def meal_params
    params.require(:meal).permit(
      :title, :published_at, :used_at, :meal_plan_id, :_destroy
      )
  end

  def meal_items_params
    params.require(:meal).permit(
      meal_items: [:id, :amount, :food_id, :_destroy] # meal_id is unnecessary to accept. It's handled above.
      )
  end

  def save_meal_items(meal_id, meal_items_params)
    meal_items = meal_items_params[:meal_items]
    meal_items.each do |new_meal_item|
      # Somehow :id="" is getting through from Angular and breaking this
      if ( (new_meal_item_id = new_meal_item[:id]) &&  (new_meal_item[:id] != "") )
        old_meal_item = MealItem.find(new_meal_item_id)
        if (new_meal_item[:_destroy] && (new_meal_item[:_destroy] == 1) )
          old_meal_item.destroy 
        else
          # old_meal_item.amount = new_meal_item[:amount] if new_meal_item[:amount].present?
          # old_meal_item.food_id = new_meal_item[:food_id] if new_meal_item[:food_id].present?
          # old_meal_item.save
          old_meal_item.update(new_meal_item)
        end
      else
        MealItem.create(amount: new_meal_item[:amount], meal_id: meal_id, food_id: new_meal_item[:food_id])
      end
    end
  end




end