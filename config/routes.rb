require 'api_constraints.rb'

Rails.application.routes.draw do
  
  resources :constraint_sets
  namespace :api, defaults: { format: :json },
                              constraints: { subdomain: 'api' }, path: '/'  do
    scope module: :v1,
              constraints: ApiConstraints.new(version: 1, default: true) do
      # We are going to list our resources here
      
      resources :foods, only: [:show, :index]
      resources :meal_plans, only: [:show, :index]
      resources :meals, only: [:show, :index] 
      resources :menu_items, only: [:show, :index] 
      resources :recipes, only: [:show, :index]
      resources :restaurant_locations, only: [:index]
      resources :restaurants, only: [:show, :index]
      resources :sessions, only: [:create, :destroy]
      resources :users, only: [:show, :index, :create, :update, :destroy] do
        resources :daily_constraint_sets, only: [:show, :index, :create, :update, :destroy] do 
          collection do
            get 'today', to: 'daily_constraint_sets#today'
          end
        end
        resources :favorites, only: [:create, :update, :destroy] do
          collection do
            post 'personal', to: 'favorites#personal'
            post 'foods', to: 'favorites#foods'
            post 'foods/add_food', to: 'favorites#add_food_to_my_foods'
            post 'menu_items', to: 'favorites#menu_items'
            post 'menu_items/add_menu_item', to: 'favorites#add_menu_item_to_my_menu_items'
            post 'recipes', to: 'favorites#recipes'
            post 'recipes/add_recipe', to: 'favorites#add_recipe_to_my_recipes'
          end
        end
        resources :meal_constraint_sets, only: [:show, :index, :create, :update, :destroy]
        resources :meal_plans, only: [:create, :update, :destroy]
        resources :meals, only: [:create, :update, :destroy]
        resources :optimize, only: [:index, :create]
        post 'pantry', to: 'pantry#show'
        patch 'pantry', to: 'pantry#update'
        post 'pantry/add_food', to: 'pantry#add_food'
        resources :recipes, only: [:create, :update, :destroy]
        post 'shopping_list', to: 'shopping_list#show'
        patch 'shopping_list', to: 'shopping_list#update'
        post 'shopping_list/add_food', to: 'shopping_list#add_food'
        post 'shopping_list/add_recipe', to: 'shopping_list#add_recipe'
        post 'shopping_list/add_meal', to: 'shopping_list#add_meal'
        post 'shopping_list/add_meal_plan', to: 'shopping_list#add_meal_plan'
      end
    end
    devise_for :users
  end
end
