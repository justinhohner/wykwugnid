class API::V1::RecipesController < ApplicationController
  before_action :authenticate_with_token!, only: [:create, :update, :destroy]
  respond_to :json

  def index
    @recipes =  Recipe.search(params).page(params[:page]).per(params[:per_page])
    render json: @recipes, meta: pagination(@recipes, params[:per_page])
  end

  def show
    respond_with Recipe.find(params[:id]), status: 200
  end

  def create
    recipe = current_user.recipes.build(recipe_params)
    if recipe.save
      save_ingredients(recipe.id, ingredients_params) unless ingredients_params.empty?
      # Automatically save to My Recipes
      @my_recipes = current_user.sources.find_by(title: 'My Recipes', personal: false)
      SourceItem.create(source_id: @my_recipes.id, food_id: recipe.id)
      recipe.reload
      render json: recipe, status: 201, location: [:api, recipe]
    else
      render json: { errors: recipe.errors }, status: 422
    end
  end

  def update
    recipe = current_user.recipes.find(params[:id])
    if recipe.update(recipe_params)
      save_ingredients(recipe.id, ingredients_params) unless ingredients_params.empty?
      save_directions(recipe.id, directions_params) unless directions_params.empty?
      recipe.reload
      render json: recipe, status: 200, location: [:api, recipe]
    else
      render json: { errors: recipe.errors }, status: 422
    end
  end

  def destroy
    recipe = current_user.recipes.find(params[:id])
    recipe.destroy
    head 204
  end

  private

  def recipe_params
    params.require(:recipe).permit(:title, :published_at, :hr, :min)
  end

  def ingredients_params
    params.require(:recipe).permit(
      ingredients: [:id, :amount, :food_id, :_destroy]
      )
  end

  def directions_params
    params.require(:recipe).permit(
      directions: [:id, :position, :step, :_destroy]
      )
  end
  
  def save_ingredients(recipe_id, ingredients_params)
    ingredients = ingredients_params[:ingredients]
    ingredients.each do |new_ingredient|
      if ( (new_ingredient_id = new_ingredient[:id]) &&  (new_ingredient[:id] != "") )
        old_ingredient = Ingredient.find(new_ingredient_id)
        if (new_ingredient[:_destroy] && (new_ingredient[:_destroy] == 1) )
          old_ingredient.destroy 
        else
          old_ingredient.update(amount: new_ingredient[:amount], food_id: new_ingredient[:food_id]);
        end
      else
        Ingredient.create(recipe_id: recipe_id, amount: new_ingredient[:amount], food_id: new_ingredient[:food_id])
      end
    end
  end

  def save_directions(recipe_id, directions_params)
    directions = directions_params[:directions]
    directions.each do |new_direction|
      if ( (new_direction_id = new_direction[:id]) &&  (new_direction[:id] != "") )
        old_direction = Direction.find(new_direction_id)
        if (new_direction[:_destroy] && (new_direction[:_destroy] == 1) )
          old_direction.destroy 
        else
          old_direction.update(position: new_direction[:position], step: new_direction[:step]);
        end
      else
        Direction.create(recipe_id: recipe_id, position: new_direction[:position], step: new_direction[:step])
      end
    end
  end

end