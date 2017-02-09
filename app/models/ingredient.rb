class Ingredient < ApplicationRecord
  after_save :update_parents_nutrients
  #after_destroy :update_parents_nutrients

  belongs_to :recipe, inverse_of: :ingredients
  belongs_to :food, inverse_of: :ingredients

  def update_parents_nutrients
    self.recipe.save
  end

end
