class RestaurantLocation < Location
    belongs_to :restaurant

    scope :by_above_or_equal_to_lat, ->(lat) { where('lat >= ?', lat) }
    scope :by_below_or_equal_to_lat, ->(lat) { where('lat <= ?', lat) }
    scope :by_above_or_equal_to_lng, ->(lng) { where('lng >= ?', lng) }
    scope :by_below_or_equal_to_lng, ->(lng) { where('lng <= ?', lng) }

    def self.search(params = {})
        restaurant_locations = params[:restaurant_location_ids].present? ? RestaurantLocation.where(id: params[:restaurant_location_ids].split(',')) : RestaurantLocation.all 
        restaurant_locations = restaurant_locations.select {|loc| loc.getDistance(params[:lat].to_f, params[:lng].to_f) <= params[:max_distance].to_f} if  params[:max_distance] && params[:lat] && params[:lng]
        restaurant_locations = restaurant_locations.by_above_or_equal_to_lat(params[:min_lat].to_f) if params[:min_lat]
        restaurant_locations = restaurant_locations.by_below_or_equal_to_lat(params[:max_lat].to_f) if params[:max_lat]
        restaurant_locations = restaurant_locations.by_above_or_equal_to_lng(params[:min_lng].to_f) if params[:min_lng]
        restaurant_locations = restaurant_locations.by_below_or_equal_to_lng(params[:max_lng].to_f) if params[:max_lng]
        restaurant_locations
    end
end
