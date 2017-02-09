class MenuItem < Food
    has_many :menu_item_ingredients
    has_many :foods, through: :menu_item_ingredients
    has_many :menu_join_menu_items
    has_many :menus, through: :menu_join_menu_items
    has_one :restaurant_join_menu_item
    has_one :restaurant, through: :restaurant_join_menu_item # This should be belongs to

    validates :price, numericality: { greater_than_or_equal_to: 0 },
                    presence: true

    scope :filter_by_restaurant_ids, ->(restaurant_ids) { where(id: RestaurantJoinMenuItem.where(restaurant_id: restaurant_ids.split(',')).pluck(:menu_item_id)) }
    scope :by_above_or_equal_to_price, ->(price) { where('price >= ?', price) }
    scope :by_below_or_equal_to_price, ->(price) { where('price <= ?', price) }
    scope :allowed_foods, ->(allowed_food_ids) { where.not(id: MenuItemIngredient.where.not(food_id: allowed_food_ids.split(',').uniq).pluck(:menu_item_id))}
    scope :at_least_one_of_foods, ->(at_least_one_of_food_ids) { where(id: Ingredient.where(food_id: at_least_one_of_food_ids.split(',').uniq).pluck(:menu_item_id))}
    scope :excluded_foods, ->(excluded_food_ids) { where.not(id: MenuItemIngredient.where(food_id: excluded_food_ids.split(',').uniq).pluck(:menu_item_id))}
    

    def self.search(params = {})
        menu_items = params[:menu_item_ids].present? ? MenuItem.where(id: params[:menu_item_ids].split(',')) : MenuItem.all
        # THESE MAY NOT BE CHAINING CORRECTLY SINCE I'M NOT USING SCOPE
        menu_items = menu_items.filter_by_restaurant_ids(params[:restaurant_ids]) if params[:restaurant_ids]  && (params[:restaurant_ids].length > 0)
        menu_items = menu_items.filter_by_title(params[:keyword]) if params[:keyword]
        menu_items = menu_items.by_above_or_equal_to_calories(params[:min_calories]) if params[:min_calories]
        menu_items = menu_items.by_below_or_equal_to_calories(params[:max_calories]) if params[:max_calories]
        menu_items = menu_items.by_above_or_equal_to_fat(params[:min_fat]) if params[:min_fat]
        menu_items = menu_items.by_below_or_equal_to_fat(params[:max_fat]) if params[:max_fat]
        menu_items = menu_items.by_above_or_equal_to_carbohydrates(params[:min_carbohydrates]) if params[:min_carbohydrates]
        menu_items = menu_items.by_below_or_equal_to_carbohydrates(params[:max_carbohydrates]) if params[:max_carbohydrates]
        menu_items = menu_items.by_above_or_equal_to_protein(params[:min_protein]) if params[:min_protein]
        menu_items = menu_items.by_below_or_equal_to_protein(params[:max_protein]) if params[:max_protein]
        menu_items = menu_items.by_above_or_equal_to_price(params[:min_price]) if params[:min_price]
        menu_items = menu_items.by_below_or_equal_to_price(params[:max_price]) if params[:max_price]
        menu_items = menu_items.allowed_foods(params[:allowed_food_ids]) if params[:allowed_food_ids]
        menu_items = menu_items.at_least_one_of_foods(params[:at_least_one_of_food_ids]) if params[:at_least_one_of_food_ids]
        menu_items = menu_items.excluded_foods(params[:excluded_food_ids]) if params[:excluded_food_ids]
        if must_contain_food_ids = params[:must_contain_food_ids]
            menu_item_ids = menu_items.pluck(:id)
            must_contain_food_ids.split(',').uniq.each { |f_id| menu_item_ids = MenuItemIngredient.where(food_id: f_id, menu_item_id: menu_item_ids).pluck(:menu_item_id)}
            menu_items = menu_items.where(id: menu_item_ids)
        end
        menu_items = menu_items.by_recently_updated(params[:recent]) if params[:recent].present?
        # menu_items.order(params[:order].to_sym) if params[:order]
        menu_items = menu_items.count if params[:count].present?
        menu_items = menu_items.order(:title)
        menu_items
    end
end
