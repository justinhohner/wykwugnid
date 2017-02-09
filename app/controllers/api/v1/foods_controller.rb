class API::V1::FoodsController < ApplicationController
    respond_to :json

    def index
        @foods =  Food.search(params).page(params[:page]).per(params[:per_page])
        render json: @foods, meta: pagination(@foods, params[:per_page])
    end

    def show
        respond_with Food.find(params[:id]), status: 200
    end
    
end
