class API::V1::MealConstraintSetsController < ApplicationController
  before_action :authenticate_with_token!, only: [:create, :update, :destroy]
  respond_to :json

  def index
    user = User.find(params[:user_id])
    respond_with user.meal_constraint_sets
  end

  def show
    user = User.find(params[:user_id])
    respond_with user.meal_constraint_sets.find(params[:id]), status: 200
  end

  def create
    meal_constraint_set = current_user.meal_constraint_sets.build(meal_constraint_set_params)
    if meal_constraint_set.save
      render json: meal_constraint_set, status: 201, location: [:api, current_user, meal_constraint_set]
    else
      render json: { errors: meal_constraint_set.errors }, status: 422
    end
  end

  def update
    meal_constraint_set = current_user.meal_constraint_sets.find(params[:id])
    if meal_constraint_set.update(meal_constraint_set_params)
      render json: meal_constraint_set, status: 200, location: [:api, current_user, meal_constraint_set]
    else
      render json: { errors: meal_constraint_set.errors }, status: 422
    end
  end

  def destroy
    meal_constraint_set = current_user.meal_constraint_sets.find(params[:id])

    meal_constraint_set.destroy
    head 204
  end

  private

    def meal_constraint_set_params
      params.require(:meal_constraint_set).permit(
          :user_id, :title, :daily_constraint_set_id, :position,
          :min_calories, :target_calories, :max_calories,
          :min_fat, :target_fat, :max_fat,
          :min_carbohydrates, :target_carbohydrates, :max_carbohydrates,
          :min_protein, :target_protein, :max_protein
          )
    end

end
