class MenuItemSerializer < ActiveModel::Serializer
  attributes :id, :title, :price, :calories, :fat, :carbohydrates, :protein,
             :restaurant_id, :restaurant_title #, :restaurant_distance
             # If there's a single menu_item in the database without a restaurant, this will break and return an error.
             # I could do a tertiary operator in the functions restaurant_id and restaurant_title to give a fake restaurant id.
  has_many :menu_item_ingredients

  def restaurant_id
    object.restaurant.id
  end

  def restaurant_title
    object.restaurant.title
  end
 
end
