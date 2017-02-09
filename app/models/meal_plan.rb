class MealPlan < ApplicationRecord
  before_save :update_nutrients
  
  validates :user_id, presence: true # Removed title requirement
  validates :calories, numericality: { greater_than_or_equal_to: 0 },
                    presence: true
  validates :fat, numericality: { greater_than_or_equal_to: 0 },
                    presence: true
  validates :carbohydrates, numericality: { greater_than_or_equal_to: 0 },
                    presence: true
  validates :protein, numericality: { greater_than_or_equal_to: 0 },
                    presence: true
  belongs_to :user
  has_many :meals
  has_many :meal_items, through: :meals

  scope :filter_by_title, ->(keyword) { where('lower(title) LIKE ?', "%#{keyword.downcase}%") }
  scope :filter_published, ->() { where.not(published_at: nil) }
  scope :filter_my_meal_plans_user_id, ->(user_id) { where(user_id: user_id) }
  scope :filter_my_meal_plans_never_used, ->() { where(used_at: nil) }
  scope :by_above_or_equal_to_calories, ->(calories) { where('calories >= ?', calories) }
  scope :by_below_or_equal_to_calories, ->(calories) { where('calories <= ?', calories) }
  scope :by_above_or_equal_to_fat, ->(fat) { where('fat >= ?', fat) }
  scope :by_below_or_equal_to_fat, ->(fat) { where('fat <= ?', fat) }
  scope :by_above_or_equal_to_carbohydrates, ->(carbohydrates) { where('carbohydrates >= ?', carbohydrates) }
  scope :by_below_or_equal_to_carbohydrates, ->(carbohydrates) { where('carbohydrates <= ?', carbohydrates) }
  scope :by_above_or_equal_to_protein, ->(protein) { where('protein >= ?', protein) }
  scope :by_below_or_equal_to_protein, ->(protein) { where('protein <= ?', protein) }
  scope :filter_by_num_meals, ->(num_meals) { select{ |meal_plan| meal_plan.meals.count == num_meals} }
  scope :by_recently_updated, -> { order(:updated_at) }

  def self.search(params = {})
    meal_plans = params[:meal_plan_ids].present? ? MealPlan.where(id: params[:meal_plan_ids].split(',')) : MealPlan.all
    meal_plans = meal_plans.filter_by_title(params[:keyword]) if params[:keyword]
    meal_plans = meal_plans.filter_published if params[:published].present? && (params[:published] == '1')
    meal_plans = meal_plans.filter_my_meal_plans_user_id(params[:user_id]) if params[:user_id].present?
    meal_plans = meal_plans.filter_my_meal_plans_never_used if params[:my_meal_plans].present? && (params[:my_meal_plans] == '1')
    meal_plans = meal_plans.by_above_or_equal_to_calories(params[:min_calories]) if params[:min_calories]
    meal_plans = meal_plans.by_below_or_equal_to_calories(params[:max_calories]) if params[:max_calories]
    meal_plans = meal_plans.by_above_or_equal_to_fat(params[:min_fat]) if params[:min_fat]
    meal_plans = meal_plans.by_below_or_equal_to_fat(params[:max_fat]) if params[:max_fat]
    meal_plans = meal_plans.by_above_or_equal_to_carbohydrates(params[:min_carbohydrates]) if params[:min_carbohydrates]
    meal_plans = meal_plans.by_below_or_equal_to_carbohydrates(params[:max_carbohydrates]) if params[:max_carbohydrates]
    meal_plans = meal_plans.by_above_or_equal_to_protein(params[:min_protein]) if params[:min_protein]
    meal_plans = meal_plans.by_below_or_equal_to_protein(params[:max_protein]) if params[:max_protein]
    meal_plans = meal_plans.by_recently_updated(params[:recent]) if params[:recent].present?
    meal_plans = meal_plans.filter_by_num_meals( (params[:num_meals]).to_i ) if params[:num_meals]
    # THIS LINE IS NOT TESTED
    meal_plans = meal_plans.select { |mp| MealPlan.fitsMyPrimaryDailyConstraints(mp, 53) } if params[:fits_my_daily_constraints] && (params[:fits_my_daily_constraints] == '1')
    meal_plans
  end

  def update_nutrients
      self.calories = self.meals.inject(0){|sum, obj| sum + obj.calories }
      self.fat = self.meals.inject(0){|sum, obj| sum + obj.fat }
      self.carbohydrates = self.meals.inject(0){|sum, obj| sum + obj.carbohydrates }
      self.protein = self.meals.inject(0){|sum, obj| sum + obj.protein }
  end

  def self.fitsMyPrimaryDailyConstraints(meal_plan, user_id)
    @user = User.find(user_id)
    @dcs = @user.daily_constraint_sets.find_by(primary: true)
    return false if @dcs.meal_constraint_sets.length != meal_plan.meals.length
    return false unless fitsNutrientConstraints(@dcs, meal_plan)
    @dcs.meal_constraint_sets.each_with_index do |mcs, index|
      return false unless MealPlan.fitsNutrientConstraints(@dcs.meal_constraint_sets[index],meal_plan.meals[index])
    end
    true
  end

  def self.fitsNutrientConstraints(constraint_set, plan)
    return false unless ( constraint_set.min_calories <= plan.calories ) && ( plan.calories <= constraint_set.max_calories )
    return false unless ( constraint_set.min_fat <= plan.fat ) && ( plan.calories <= constraint_set.max_fat )
    return false unless ( constraint_set.min_carbohydrates <= plan.carbohydrates ) && ( plan.calories <= constraint_set.max_carbohydrates )
    return false unless ( constraint_set.min_protein <= plan.protein ) && ( plan.calories <= constraint_set.max_protein )
    true
  end
  
end
