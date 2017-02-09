class API::V1::PantryController < ApplicationController
  before_action :authenticate_with_token!
  respond_to :json

  def show
    render json: current_user.pantry, status: 200, location: [:api, current_user, @pantry]
  end

  def update
    @pantry = current_user.pantry
    save_pantry_items(@pantry.id, pantry_items_params) unless pantry_items_params.empty?
    if @pantry.reload
      render json: @pantry, status: 200, location: [:api, current_user, @pantry]
    else
      render json: { errors: @pantry.errors }, status: 422
    end
  end

  def add_food
    @pantry = current_user.pantry
    save_food(@pantry.id, food_params) unless food_params.empty?
    if @pantry.reload
      render json: @pantry, status: 200, location: [:api, current_user, @pantry]
    else
      render json: { errors: @pantry.errors }, status: 422
    end
  end

  private

  def pantry_items_params
    params.require(:pantry).permit( pantry_items: [:id, :amount, :food_id, :_destroy] )
  end

  def food_params
    params.require(:pantry).permit(foods: [:amount, :food_id])
  end

  def save_pantry_items(pantry_id, pantry_items_params)
    pantry_items = pantry_items_params[:pantry_items]
    pantry_items.each do |new_pantry_item|
      if ( (new_pantry_item_id = new_pantry_item[:id]) &&  (new_pantry_item[:id] != "") )
        old_pantry_item = PantryItem.find(new_pantry_item_id)
        if (new_pantry_item[:_destroy] && (new_pantry_item[:_destroy] == 1) )
          old_pantry_item.destroy 
        else
          # old_pantry_item.amount = new_pantry_item[:amount] if new_pantry_item[:amount].present?
          # old_pantry_item.food_id = new_pantry_item[:food_id] if new_pantry_item[:food_id].present?
          # old_pantry_item.save
          old_pantry_item.update(amount: new_pantry_item[:amount], food_id: new_pantry_item[:food_id])
        end
      else
        PantryItem.create(amount: new_pantry_item[:amount], pantry_id: pantry_id, food_id: new_pantry_item[:food_id])
      end
    end
  end

  def save_food(pantry_id, food_params)
    food_params[:foods].each do |item|
      PantryItem.create(pantry_id: pantry_id, amount: item[:amount], food_id: item[:food_id])
    end
  end
end
