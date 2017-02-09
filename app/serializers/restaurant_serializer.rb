class RestaurantSerializer < ActiveModel::Serializer
  cache key: 'restaurant', expires_in: 30.minutes
  
  attributes :id, :title, :menu_item_ids

  private
  def menu_item_ids
    object.meal_items.pluck(:id)
  end
end
