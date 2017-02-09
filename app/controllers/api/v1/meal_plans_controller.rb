class API::V1::MealPlansController < ApplicationController
  before_action :authenticate_with_token!, only: [:create, :update, :destroy, :today]
  respond_to :json

  def index
    respond_with MealPlan.search(params), include: { meals: [ :meal_items ] }
    # Change to this when I need pagination
    # @meal_plans =  MealPlan.search(params).page(params[:page]).per(params[:per_page])
    # render json: @meal_plans, include: { meals: [ :meal_items ] }, meta: pagination(@meal_plans, params[:per_page])
  end

  def show
    respond_with MealPlan.find(params[:id]),  include: { meals: [ :meal_items ] }, status: 200
  end

  def create
    meal_plan = current_user.meal_plans.build(meal_plan_params)
    if meal_plan.save
      save_meals(meal_plan.id, meals_params) unless meals_params.empty?
      meal_plan.reload
      render json: meal_plan, include: { meals: [ :meal_items ] }, status: 201, location: [:api, meal_plan]
    else
      render json: { errors: meal_plan.errors }, status: 422
    end
  end

  def update
    meal_plan = current_user.meal_plans.find(params[:id])
    if meal_plan.update(meal_plan_params)
      save_meals(meal_plan.id, meals_params) unless meals_params.empty?
      #meal_plan.update_nutrients
      meal_plan.reload
      render json: meal_plan, include: { meals: [ :meal_items ] }, status: 200, location: [:api, meal_plan]
    else
      render json: { errors: meal_plan.errors }, status: 422
    end
  end

  def destroy
    meal_plan = current_user.meal_plans.find(params[:id])
    meal_plan.destroy
    head 204
  end

  private

  def meal_plan_params
    params.require(:meal_plan).permit(:title, :published_at, :used_at)
  end

  def meals_params
    params.require(:meal_plan).permit(
      :used_at,
      meals: [:id, :title, :position, :published_at, :used_at, :meal_plan_id, :_destroy,
              meal_items: [:id, :amount, :food_id, :_destroy]
            ]
      ) 
  end

  def meal_items_params
    params.require(:meal_plan).permit(
      meals: [ meal_items: [:id, :amount, :food_id, :_destroy] ]
      ) 
  end
  

  
  def save_meals(meal_plan_id, meals_params)
    meals_with_items = meal_items_params[:meals]
    meals = meals_params[:meals]
    meals.each_with_index do |new_meal, idx|
      if ( (new_meal_id = new_meal[:id]) &&  (new_meal[:id] != "") )
        old_meal = Meal.find(new_meal_id)
        if (new_meal[:_destroy] && (new_meal[:_destroy] == 1) )
          old_meal.destroy
        else
          old_meal.title = new_meal[:title] if new_meal[:title].present?
          #save_meals_items(new_meal_id, meals_with_items[idx])
          if meal_items = meals_with_items[idx] and not meals_with_items[idx].empty?
            save_meals_items(new_meal_id, meal_items)
          end
          old_meal.save
        end
      else
        created_meal = Meal.create(title: new_meal[:title], meal_plan_id: meal_plan_id, user_id: current_user.id, position: new_meal[:position])
        # CHECK WHAT'S GOING ON IN THIS IF-STATEMENT. THIS IS WEIRD.
        if meal_items = meals_with_items[idx] and not meals_with_items[idx].empty?
          save_meals_items(created_meal.id, meal_items)
        end
        created_meal.save
      end
    end
  end

  def save_meals_items(meal_id, meal_items_params)
    meal_items = meal_items_params[:meal_items]
    meal_items.each do |new_meal_item|
      if ( (new_meal_item_id = new_meal_item[:id]) &&  (new_meal_item[:id] != "") )
        old_meal_item = MealItem.find(new_meal_item_id)
        if (new_meal_item[:_destroy] && (new_meal_item[:_destroy] == 1) )
          old_meal_item.destroy 
        else
          # I can't currently use old_meal_item.update(new_meal_item), I think because 
          # if new_meal_item[_destroy: ''] gets through, the update fails.
          old_meal_item.update(amount: new_meal_item[:amount], food_id: new_meal_item[:food_id])
        end
      else
        MealItem.create(amount: new_meal_item[:amount], meal_id: meal_id, food_id: new_meal_item[:food_id])
      end
    end
  end

end



