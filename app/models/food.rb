class Food < ApplicationRecord
    #belongs_to :category
    #has_attached_file :image, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
    #validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/
    #has_many :directions
    #has_many :ingredients
    #accepts_nested_attributes_for :directions,
  	#	reject_if: proc { |attributes| attributes[:step].blank? },
  	#	allow_destroy: true
    #accepts_nested_attributes_for :ingredients,
  	#	reject_if: proc { |attributes| attributes[:ingredient_id].blank? },
    #    reject_if: proc { |attributes| attributes[:amount].blank? or attributes[:amount].to_i <= 0},
    #    allow_destroy: true
  		
          
    #def category_name
    #    category.try(:name)
    #end
    
    #def category_name=(name)
    #    self.category = Category.find_or_create_by(name: name) if name.present?
    #end


    validates :title, presence: true
    validates :calories, numericality: { greater_than_or_equal_to: 0 },
                        presence: true
    validates :fat, numericality: { greater_than_or_equal_to: 0 },
                        presence: true
    validates :carbohydrates, numericality: { greater_than_or_equal_to: 0 },
                        presence: true
    validates :protein, numericality: { greater_than_or_equal_to: 0 },
                        presence: true

    has_many :ingredients
    has_many :recipes, through: :ingredients
    has_many :meal_items
    has_many :meals, through: :meal_items
    has_many :menu_item_ingredients
    has_many :menu_items, through: :menu_item_ingredients
    has_many :food_sources
    has_many :source_items
    has_many :pantry_items
    has_many :pantries, through: :pantry_items
    has_many :shopping_list_items
    has_many :shopping_lists, through: :shopping_list_items

    scope :filter_by_title, ->(keyword) { where('lower(title) LIKE ?', "%#{keyword.downcase}%") }
    scope :foods_only, ->() { where(type: nil) }
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
        foods = params[:food_ids].present? ? Food.where(id: params[:food_ids].split(',')) : Food.all 
        foods = foods.foods_only if params[:foods_only]
        foods = foods.filter_by_title(params[:keyword]) if params[:keyword]
        foods = foods.by_above_or_equal_to_calories(params[:min_calories]) if params[:min_calories]
        foods = foods.by_below_or_equal_to_calories(params[:max_calories]) if params[:max_calories]
        foods = foods.by_above_or_equal_to_fat(params[:min_fat]) if params[:min_fat]
        foods = foods.by_below_or_equal_to_fat(params[:max_fat]) if params[:max_fat]
        foods = foods.by_above_or_equal_to_carbohydrates(params[:min_carbohydrates]) if params[:min_carbohydrates]
        foods = foods.by_below_or_equal_to_carbohydrates(params[:max_carbohydrates]) if params[:max_carbohydrates]
        foods = foods.by_above_or_equal_to_protein(params[:min_protein]) if params[:min_protein]
        foods = foods.by_below_or_equal_to_protein(params[:max_protein]) if params[:max_protein]
        foods = foods.by_recently_updated(params[:recent]) if params[:recent].present?
        #params[:order] ? foods.order(params[:order].to_sym) : foods.order(:title)
        foods = foods.count if params[:count].present?
        foods = foods.order(:title)
        foods
    end
end
