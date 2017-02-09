class MenuSerializer < ActiveModel::Serializer
  attributes :id, :title
  has_one :restaurant
  has_many :menu_items

end
