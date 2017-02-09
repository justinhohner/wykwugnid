class API::V1::FavoritesController < ApplicationController
    before_action :authenticate_with_token!
    respond_to :json

    def personal
        render json: current_user.sources.where(personal: true), status: 200
    end
    def foods
        render json: current_user.sources.find_by(title: 'My Foods', personal: false), status: 200
    end

    def menu_items
        render json: current_user.sources.find_by(title: 'My Menu Items', personal: false), status: 200
    end
    
    def recipes
        render json: current_user.sources.find_by(title: 'My Recipes', personal: false), status: 200
    end

    def create
        @source = current_user.sources.build(source_params)
        if @source.save
            save_source_items(@source.id, source_items_params) unless source_items_params.empty?
            @source.reload
            render json: @source, status: 201
        else
            render json: { errors: @source.errors }, status: 422
        end
    end

    def update
        @source = current_user.sources.find(params[:id])
        if @source.update(source_params)
            save_source_items(@source.id, source_items_params) unless source_items_params.empty?
            @source.reload
            render json: @source, status: 200
        else
            render json: { errors: @source.errors }, status: 422
        end
    end

    def destroy
        @source = current_user.sources.find(params[:id])
        @source.destroy
        head 204
    end

    def add_food_to_my_foods
        @my_foods = current_user.sources.find_by(title: 'My Foods', personal: false)
        save_food(@my_foods.id, food_params) unless food_params.empty?
        if @my_foods.reload
            render json: @my_foods, status: 200
        else
            render json: { errors: @my_foods.errors }, status: 422
        end
    end

    def add_menu_item_to_my_menu_items
        @my_menu_items = current_user.sources.find_by(title: 'My Menu Items', personal: false)
        save_food(@my_menu_items.id, food_params) unless food_params.empty?
        if @my_menu_items.reload
            render json: @my_menu_items, status: 200
        else
            render json: { errors: @my_menu_items.errors }, status: 422
        end
    end

    def add_recipe_to_my_recipes
        @my_recipes = current_user.sources.find_by(title: 'My Recipes', personal: false)
        save_food(@my_recipes.id, food_params) unless food_params.empty?
        if @my_recipes.reload
            render json: @my_recipes, status: 200
        else
            render json: { errors: @my_recipes.errors }, status: 422
        end
    end

    private

    def source_params
        params.require(:source).permit(:id, :title, :personal, :_destroy)
    end

    def source_items_params
        params.require(:source).permit( source_items: [:id, :food_id, :_destroy])
    end

    def food_params
        params.require(:source).permit(food: :id )
    end

    def save_source_items(source_id, source_items_params)
        source_items = source_items_params[:source_items]
        source_items.each do |new_source_item|
            if ( (new_source_item_id = new_source_item[:id]) &&  (new_source_item[:id] != "") )
                old_source_item = SourceItem.find(new_source_item_id)
                if (new_source_item[:_destroy] && (new_source_item[:_destroy] == 1) )
                    old_source_item.destroy 
                end
            else
                SourceItem.create(source_id: source_id, food_id: new_source_item[:food_id])
            end
        end
    end

    def save_food(source_id, food_params)
        SourceItem.create(source_id: source_id, food_id: food_params[:food][:id])
    end
    
end
