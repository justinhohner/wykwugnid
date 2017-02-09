class API::V1::DailyConstraintSetsController < ApplicationController
  before_action :authenticate_with_token!, only: [:create, :update, :destroy]
  respond_to :json

  def index
    # This is a temporary hack to only handle input of primary search
    @user = User.find(params[:user_id])
    if params[:primary]
      @daily_constraint_set = @user.daily_constraint_sets.find_by(primary: true)
      render json: @daily_constraint_set, status: 200
    elsif params[:date]
      @date = Date.strptime(params[:date], "%m/%d/%Y")
      if @daily_constraint_set = @user.daily_constraint_sets.find_by(used_at: @date)
      else
        @daily_constraint_set = @user.daily_constraint_sets.find_by(primary: true)
        @meal_constraint_sets = @daily_constraint_set.meal_constraint_sets
        @daily_constraint_set = @daily_constraint_set.dup
        duplicate(@daily_constraint_set, @date)
        @daily_constraint_set.reload
        @meal_constraint_sets.each do |mcs|
          @tempMCS = mcs.dup
          @tempMCS.daily_constraint_set_id = @daily_constraint_set.id
          duplicate(@tempMCS, @date)
        end
      end
      render json: @daily_constraint_set, status: 200
    else
      @daily_constraint_sets = @user.daily_constraint_sets
      render json: @daily_constraint_set, status: 200
    end
  end
  
  def show
    user = User.find(params[:user_id])
    respond_with user.daily_constraint_sets.find(params[:id]), status: 200
  end

  def create
    daily_constraint_set = current_user.daily_constraint_sets.build(daily_constraint_set_params)
    if daily_constraint_set.save
      save_meal_constraint_sets(daily_constraint_set, meal_constraint_sets_params) unless meal_constraint_sets_params.empty?
      render json: daily_constraint_set, status: 201, location: [:api, current_user, daily_constraint_set]
    else
      render json: { errors: daily_constraint_set.errors }, status: 422
    end
  end

  def update
    daily_constraint_set = current_user.daily_constraint_sets.find(params[:id])
    if daily_constraint_set.update(daily_constraint_set_params)
      save_meal_constraint_sets(daily_constraint_set, meal_constraint_sets_params) unless meal_constraint_sets_params.empty?
      render json: daily_constraint_set, status: 200, location: [:api, current_user, daily_constraint_set]
    else
      render json: { errors: daily_constraint_set.errors }, status: 422
    end
  end

  def destroy
    daily_constraint_set = current_user.daily_constraint_sets.find(params[:id])
    daily_constraint_set.destroy
    head 204
  end

  def today
    @date = Date.today
    if daily_constraint_set = current_user.daily_constraint_sets.find_by(used_at: @date)
    else
      daily_constraint_set = current_user.daily_constraint_sets.find_by(primary: true)
      meal_constraint_sets = daily_constraint_set.meal_constraint_sets
      daily_constraint_set = daily_constraint_set.dup
      duplicate(daily_constraint_set, @date)
      daily_constraint_set.reload
      meal_constraint_sets.each do |mcs|
        tempMCS = mcs.dup
        tempMCS.daily_constraint_set_id = daily_constraint_set.id
        duplicate(tempMCS, @date)
      end
    end
    render json: daily_constraint_set, status: 200
  end

  private

  def daily_constraint_set_params
      params.require(:daily_constraint_set).permit(
          :id, :user_id, :title, :primary,
          :min_calories, :target_calories, :max_calories,
          :min_fat, :target_fat, :max_fat,
          :min_carbohydrates, :target_carbohydrates, :max_carbohydrates,
          :min_protein, :target_protein, :max_protein
          )
  end

  def meal_constraint_sets_params
    params.require(:daily_constraint_set).permit( 
      meal_constraint_sets: [
        :id, :user_id, :title, :daily_constraint_set_id, :position,
        :min_calories, :target_calories, :max_calories,
        :min_fat, :target_fat, :max_fat,
        :min_carbohydrates, :target_carbohydrates, :max_carbohydrates,
        :min_protein, :target_protein, :max_protein
      ])
  end

  def save_meal_constraint_sets(daily_constraint_set, meal_constraint_sets_params)
    meal_constraint_sets = meal_constraint_sets_params[:meal_constraint_sets]
    meal_constraint_sets.each do |new_meal_constraint_set|
      if new_meal_constraint_set[:id]
        MealConstraintSet.find(new_meal_constraint_set[:id]).update(new_meal_constraint_set)
      else
        new_meal_constraint_set[:user_id] = current_user.id
        daily_constraint_set.meal_constraint_sets.create(new_meal_constraint_set)
      end
    end
  end

  def duplicate(constraint_set, date)
      constraint_set.primary = false
      constraint_set.created_at = false
      constraint_set.updated_at = false
      constraint_set.used_at = date
      constraint_set.meal_plan_input_id = nil # What is this?
      constraint_set.save
  end

end
