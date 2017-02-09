class MealItem < ApplicationRecord

  after_save :update_parents_nutrients
  #after_destroy :update_parents_nutrients

  validates :meal_id, :food_id, presence: true

  validates :amount, numericality: { greater_than_or_equal_to: 0 },
                    presence: true
  belongs_to :meal, inverse_of: :meal_items
  belongs_to :food, inverse_of: :meal_items

  def update_parents_nutrients
    self.meal.save
  end
  
end
