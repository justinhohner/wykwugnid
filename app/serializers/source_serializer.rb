class SourceSerializer < ActiveModel::Serializer
  attributes :id, :personal, :title
  has_many :source_items
end
