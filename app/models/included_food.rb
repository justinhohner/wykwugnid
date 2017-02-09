class IncludedFood < ApplicationRecord
  belongs_to :foods_by_source
  has_one :food
end
