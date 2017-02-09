class API::V1::MealItemsController < ApplicationController
  respond_to :json

  def show
    respond_with MealItem.find(params[:id]), status: 200
  end

  def create
    meal = Meal.find(params[:meal_id])
    meal_item = meal.meal_items.build(meal_item_params)
    if meal_item.save
      render json: meal_item, status: 201, location: [:api, meal_item]
    else
      render json: { errors: meal_item.errors }, status: 422
    end
  end

  def update
    if meal_item.update(meal_item_params)
      render json: meal_item, status: 200, location: [:api, meal_item]
    else
      render json: { errors: meal_item.errors }, status: 422
    end
  end

  def destroy
    meal_item = MealItem.find(params[:id])
    meal_item.destroy
    head 204
  end

  private

  def meal_item_params
    params.require(:meal_item).permit(:meal_id, :food_id, :amount)
  end
end
