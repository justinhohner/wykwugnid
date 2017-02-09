class Restaurant < Source
    has_many :restaurant_join_menus, dependent: :destroy
    has_many :menus, through: :restaurant_join_menus, dependent: :destroy
    has_many :restaurant_join_menu_items, dependent: :destroy
    has_many :menu_items, through: :restaurant_join_menu_items, dependent: :destroy
    has_many :restaurant_locations

    validates :title, presence: true

    scope :filter_by_title, ->(keyword) { where('lower(title) LIKE ?', "%#{keyword.downcase}%") }
   

    def self.search(params = {})
        restaurants = params[:restaurant_ids].present? ? Restaurant.where(id: params[:restaurant_ids].split(',')) : Restaurant.all 
        restaurants = restaurants.filter_by_title(params[:keyword]) if params[:keyword]
        # restaurants.order(params[:order].to_sym) if params[:order] # THIS MAY BE UNUSED, BUT COULD BE USED FOR TITLE SORTING
        restaurants = restaurants.order(:title)
        restaurants.sort_by { |r| r.restaurant_locations.empty? ? 9999 : r.nearest_location(params[:location])[1] } if params[:sort_by_distance] && params[:sort_by_distance] == 1 && params[:location]
        restaurants = restaurants.select {|r| r.nearest_location(params[:location])[1] <= params[:max_distance].to_f unless r.restaurant_locations.empty? } if  params[:max_distance] && params[:location]
        restaurants
    end

    def nearest_location(location)
        blo = lambda {|loc1,loc2| loc1.getDistance(location)  <=> loc2.getDistance(location) }
        nearest_location = self.restaurant_locations.min &blo
        distance = nearest_location.getDistance(location.lat, location.lng)
        return nearest_location, distance
    end

end
