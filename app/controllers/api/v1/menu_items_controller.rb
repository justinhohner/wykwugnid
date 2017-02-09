class API::V1::MenuItemsController < ApplicationController
    respond_to :json

    def index
        @menu_items =  MenuItem.search(params).page(params[:page]).per(params[:per_page])
        render json: @menu_items, meta: pagination(@menu_items, params[:per_page])
    end

    def show
        respond_with MenuItem.find(params[:id]), status: 200
    end
end
