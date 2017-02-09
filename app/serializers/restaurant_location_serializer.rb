class RestaurantLocationSerializer < ActiveModel::Serializer
  attributes :id, :lat, :lng, :formatted_address, :place_id, :restaurant_id, :restaurant_title

  def restaurant_title
    object.restaurant.title
  end
end
