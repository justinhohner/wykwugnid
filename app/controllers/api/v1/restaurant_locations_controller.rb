class API::V1::RestaurantLocationsController < ApplicationController
  respond_to :json

  def index
    respond_with RestaurantLocation.search(params)
  end
end
