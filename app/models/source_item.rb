class SourceItem < ApplicationRecord
  belongs_to :source, inverse_of: :source_items
  belongs_to :food, inverse_of: :source_items
end
