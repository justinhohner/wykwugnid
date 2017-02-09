class Location < ApplicationRecord
    require 'haversine'
    require 'net/http'

    MAPS_ROOT_URL_JSON = 'https://maps.googleapis.com/maps/api/geocode/json?'
    API_KEY = 'AIzaSyBCIxnYbPqFvTVWpLoljrualjSs5rO2fyE' 
    
    
    def self.search(params = {})
        locations = params[:location_ids].present? ? Location.where(id: params[:location_ids].split(',')) : Location.all
        locations = locations.select {|loc| loc.getDistance(params[:lat], params[:lng]) <= params[:max_distance]} if  params[:max_distance] && params[:lat] && params[:lng]
        locations
    end

    def getDistance(lat, lng)
        # Source: https://github.com/kristianmandrup/haversine
        # Returns miles
        # Handle case of inputting a location
        Haversine.distance(self.lat, self.lng, lat, lng).to_mi 
    end

    def geocode()
        url = MAPS_ROOT_URL_JSON.dup
        url << 'address='
        url << self.formatted_address.gsub(" ","+").gsub(",","")
        url << '&key='
        url << API_KEY
        response = getHTTP(url)
        return response["results"][0]["geometry"]["location"]
    end
    
    def reverseGeocode()
        url = MAPS_ROOT_URL_JSON.dup
        url << 'latlng='
        url << self.lat.to_s << ','
        url << self.lng.to_s
        url << '&key='
        url << API_KEY  
        response = getHTTP(url)
        return response["results"][0]["formatted_address"] 
    end

    def nearest_location(locations)
        # Using all restaurant's locations for now
        blo = lambda {|loc1,loc2| self.getDistance(loc1.lat, loc1.lng) <=> self.getDistance(loc2.lat, loc2.lng)}
        nearest_location = locations.min &blo
        distance = self.getDistance(nearest_location.lat, nearest_location.lng)
        return nearest_location, distance
    end

    def getHTTP(url)
        uri = URI(url)
        response = Net::HTTP.get(uri)
        return JSON.parse(response)
    end

end
