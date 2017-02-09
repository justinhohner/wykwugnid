class Meal < ApplicationRecord

  before_save :update_nutrients 
  after_save :update_parents_nutrients
  #after_destroy :update_parents_nutrients
  
  belongs_to :user
  has_many :foods, through: :meal_items
  has_many :meal_items, dependent: :destroy
  belongs_to :meal_plan, inverse_of: :meals

  validates :user_id, presence: true
  validates :calories, numericality: { greater_than_or_equal_to: 0 },
                    presence: true
  validates :fat, numericality: { greater_than_or_equal_to: 0 },
                    presence: true
  validates :carbohydrates, numericality: { greater_than_or_equal_to: 0 },
                    presence: true
  validates :protein, numericality: { greater_than_or_equal_to: 0 },
                    presence: true
  
  accepts_nested_attributes_for :meal_items, allow_destroy: true

  scope :filter_by_title, ->(keyword) { where('lower(title) LIKE ?', "%#{keyword.downcase}%") }
  scope :filter_published, ->() {where.not(published_at: nil)}
  scope :filter_my_meals_user_id, ->(user_id) { where(user_id: user_id) }
  scope :filter_my_meals_never_used, ->() { where(used_at: nil, meal_plan_id: 1) }
  scope :by_above_or_equal_to_calories, ->(calories) { where('calories >= ?', calories) }
  scope :by_below_or_equal_to_calories, ->(calories) { where('calories <= ?', calories) }
  scope :by_above_or_equal_to_fat, ->(fat) { where('fat >= ?', fat) }
  scope :by_below_or_equal_to_fat, ->(fat) { where('fat <= ?', fat) }
  scope :by_above_or_equal_to_carbohydrates, ->(carbohydrates) { where('carbohydrates >= ?', carbohydrates) }
  scope :by_below_or_equal_to_carbohydrates, ->(carbohydrates) { where('carbohydrates <= ?', carbohydrates) }
  scope :by_above_or_equal_to_protein, ->(protein) { where('protein >= ?', protein) }
  scope :by_below_or_equal_to_protein, ->(protein) { where('protein <= ?', protein) }
  scope :by_recently_updated, -> { order(:updated_at) }

  def self.search(params = {})
    meals = params[:meal_ids].present? ? Meal.where(id: params[:meal_ids].split(',')) : Meal.all
    meals = meals.filter_by_title(params[:keyword]) if params[:keyword]
    meals = meals.filter_published if params[:published].present? && params[:published].to_i == 1
    meals = meals.filter_my_meals_user_id(params[:user_id].to_i) if params[:user_id]
    meals = meals.filter_my_meals_never_used if params[:my_meals] && params[:my_meals].to_i == 1
    meals = meals.by_above_or_equal_to_calories(params[:min_calories]) if params[:min_calories]
    meals = meals.by_below_or_equal_to_calories(params[:max_calories]) if params[:max_calories]
    meals = meals.by_above_or_equal_to_fat(params[:min_fat]) if params[:min_fat]
    meals = meals.by_below_or_equal_to_fat(params[:max_fat]) if params[:max_fat]
    meals = meals.by_above_or_equal_to_carbohydrates(params[:min_carbohydrates]) if params[:min_carbohydrates]
    meals = meals.by_below_or_equal_to_carbohydrates(params[:max_carbohydrates]) if params[:max_carbohydrates]
    meals = meals.by_above_or_equal_to_protein(params[:min_protein]) if params[:min_protein]
    meals = meals.by_below_or_equal_to_protein(params[:max_protein]) if params[:max_protein]
    meals = meals.by_recently_updated(params[:recent]) if params[:recent].present?

    meals
  end

  def update_nutrients
    self.calories = self.meal_items.inject(0){|sum, obj| sum + obj.amount * obj.food.calories }
    self.fat = self.meal_items.inject(0){|sum, obj| sum + obj.amount * obj.food.fat }
    self.carbohydrates = self.meal_items.inject(0){|sum, obj| sum + obj.amount * obj.food.carbohydrates }
    self.protein = self.meal_items.inject(0){|sum, obj| sum + obj.amount * obj.food.protein }
  end

  def update_parents_nutrients
    self.meal_plan.save unless self.meal_plan.id == 1
  end

end
