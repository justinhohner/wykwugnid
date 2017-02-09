class Recipe < Food
    before_save :update_nutrients 

    belongs_to :user
    has_many :directions, dependent: :destroy
    has_many :ingredients, dependent: :destroy
    has_many :foods, through: :ingredients

    validates :title, :user_id, presence: true
    validates :calories, numericality: { greater_than_or_equal_to: 0 },
                        presence: true
    validates :fat, numericality: { greater_than_or_equal_to: 0 },
                        presence: true
    validates :carbohydrates, numericality: { greater_than_or_equal_to: 0 },
                        presence: true
    validates :protein, numericality: { greater_than_or_equal_to: 0 },
                        presence: true

    scope :filter_published, ->() {where.not(published_at: nil)}
    scope :filter_by_below_or_equal_to_max_hr, ->(max_hr) { where('hr <= ?', max_hr) }
    scope :filter_by_below_or_equal_to_max_min, ->(max_min) { where('min <= ?', max_min) }
    scope :allowed_ingredients, ->(allowed_food_ids) { where.not(id: Ingredient.where.not(food_id: allowed_food_ids.split(',').uniq).pluck(:recipe_id))}
    scope :at_least_one_of_ingredients, ->(at_least_one_of_food_ids) { where(id: Ingredient.where(food_id: at_least_one_of_food_ids.split(',').uniq).pluck(:recipe_id))}
    scope :excluded_ingredients, ->(excluded_food_ids) { where.not(id: Ingredient.where(food_id: excluded_food_ids.split(',').uniq).pluck(:recipe_id))}

    def self.search(params = {})
        recipes = params[:recipe_ids].present? ? Recipe.where(id: params[:recipe_ids].split(',')) : Recipe.all
        recipes = recipes.filter_by_title(params[:keyword]) if params[:keyword]
        recipes = recipes.filter_published if params[:published].present? && (params[:published].to_i == 1)
        recipes = recipes.filter_by_below_or_equal_to_max_hr(params[:max_hr].to_i) if params[:max_hr]
        recipes = recipes.filter_by_below_or_equal_to_max_min(params[:max_min].to_i) if params[:max_min]
        recipes = recipes.by_above_or_equal_to_calories(params[:min_calories]) if params[:min_calories]
        recipes = recipes.by_below_or_equal_to_calories(params[:max_calories]) if params[:max_calories]
        recipes = recipes.by_above_or_equal_to_fat(params[:min_fat]) if params[:min_fat]
        recipes = recipes.by_below_or_equal_to_fat(params[:max_fat]) if params[:max_fat]
        recipes = recipes.by_above_or_equal_to_carbohydrates(params[:min_carbohydrates]) if params[:min_carbohydrates]
        recipes = recipes.by_below_or_equal_to_carbohydrates(params[:max_carbohydrates]) if params[:max_carbohydrates]
        recipes = recipes.by_above_or_equal_to_protein(params[:min_protein]) if params[:min_protein]
        recipes = recipes.by_below_or_equal_to_protein(params[:max_protein]) if params[:max_protein]
        recipes = recipes.allowed_ingredients(params[:allowed_food_ids]) if params[:allowed_food_ids]
        recipes = recipes.at_least_one_of_ingredients(params[:at_least_one_of_food_ids]) if params[:at_least_one_of_food_ids]
        recipes = recipes.excluded_ingredients(params[:excluded_food_ids]) if params[:excluded_food_ids]
        if must_contain_food_ids = params[:must_contain_food_ids]
            recipe_ids = recipes.pluck(:id)
            must_contain_food_ids.split(',').uniq.each { |f_id| recipe_ids = Ingredient.where(food_id: f_id, recipe_id: recipe_ids).pluck(:recipe_id)}
            recipes = recipes.where(id: recipe_ids)
        end
        recipes = recipes.by_recently_updated(params[:recent]) if params[:recent].present?
        recipes.order(params[:order].to_sym) if params[:order]
        recipes = recipes.count if params[:count].present?
        recipes
    end

    def update_nutrients
        self.calories = self.ingredients.inject(0){|sum, obj| sum + obj.amount * obj.food.calories }
        self.fat = self.ingredients.inject(0){|sum, obj| sum + obj.amount * obj.food.fat }
        self.carbohydrates = self.ingredients.inject(0){|sum, obj| sum + obj.amount * obj.food.carbohydrates }
        self.protein = self.ingredients.inject(0){|sum, obj| sum + obj.amount * obj.food.protein }
    end
    
end
  