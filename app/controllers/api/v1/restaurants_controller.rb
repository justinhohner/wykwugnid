class API::V1::RestaurantsController < ApplicationController
    respond_to :json

    def index
        # Get rid of this if clause creating a location. Only use lat & lng
        if (!params[:location] && params[:lat] && params[:lng]) 
            params[:location] = Location.new(lat: params[:lat], lng: params[:lng])
        end
        @restaurants =  Restaurant.search(params).page(params[:page]).per(params[:per_page])
        render json: @restaurants, meta: pagination(@restaurants, params[:per_page])
    end

    def show
        respond_with Restaurant.find(params[:id]), status: 200
    end
end
