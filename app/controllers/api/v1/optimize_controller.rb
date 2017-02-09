class API::V1::OptimizeController < ApplicationController
  before_action :authenticate_with_token!
  respond_to :json
  NUTRIENTS = [:calories, :fat, :carbohydrates, :protein]

  def index
    @date = Date.strptime(params[:date], "%m/%d/%Y")
    # I'm currently not deleting saved meal plans for a given day, just retrieving the latest.
    if meal_plan = current_user.meal_plans.where(used_at: @date).last
    else
      meal_plan = current_user.meal_plans.create(used_at: @date)
      current_user.daily_constraint_sets.find_by(primary: true).meal_constraint_sets.each do |mcs|
        meal_plan.meals.create(user_id: current_user.id, title: mcs.title, position: mcs.position, used_at: @date)
      end
    end
    meal_plan.reload
    render json: meal_plan, include: { meals: [ :meal_items ] }, status: 200, location: [:api, meal_plan]
  end

  def create
    meal_plan = create_new_optimized_meal_plan(meal_plan_input_params)
    if meal_plan
      render json: meal_plan, include: { meals: [ :meal_items ] }, status: 201, location: [:api, meal_plan]
    else
      render json: { errors: "Error" }, status: 422
    end
  end
  
  private 

  def meal_plan_input_params
    params.require(:meal_plan_input).permit(
      daily_constraint_set: [
        :id, :user_id, :title,:min_calories, :target_calories, :max_calories,:min_fat, :target_fat, :max_fat,
        :min_carbohydrates, :target_carbohydrates, :max_carbohydrates,:min_protein, :target_protein, :max_protein,
        meal_constraint_sets: [
          :id, :user_id, :title, :daily_constraint_set_id, :position,
          :min_calories, :target_calories, :max_calories,
          :min_fat, :target_fat, :max_fat,
          :min_carbohydrates, :target_carbohydrates, :max_carbohydrates,
          :min_protein, :target_protein, :max_protein
        ]
      ],
      sources_by_meals: [ :position, :title,
        foods_by_sources: [ :source_id, 
          included_foods: [:food_id],
          excluded_foods: [:food_id],
          included_food_amounts: [:food_id, :amount],
        ]
      ]
    )
  end

  def create_new_optimized_meal_plan(whitelisted_params)
    preprocessed_constraints = preprocess_constraints(whitelisted_params[:daily_constraint_set])
    sources_by_meals_params = whitelisted_params[:sources_by_meals] #.sort_by { |meal| meal[:position] }
    preprocessed_nutrition_info, food_indices_by_meal = preprocess_nutrition_info(sources_by_meals_params)
    save_data_to_file(preprocessed_constraints, preprocessed_nutrition_info)
    call_optimization()
    results = read_results()
    meal_plan = convert_results_to_new_meal_plan(results, food_indices_by_meal, sources_by_meals_params)
    return meal_plan
  end

  ############# PREPROCESS CONSTRAINTS #############
  def preprocess_constraints(daily_constraint_set_params)
    dayNutrMin, dayNutrTarget, dayNutrMax = preprocess_day_objects(daily_constraint_set_params)
    meal_constraint_sets_params = daily_constraint_set_params[:meal_constraint_sets] #.sort_by { |meal| meal[:position] }  
    mealNutrMin, mealNutrTarget, mealNutrMax = preprocess_meal_objects(meal_constraint_sets_params)
    nutrWeights ||= [0.4, 0.2, 0.2, 0.2] # Hard-coding for now
    dayAndMealWeights ||= [0.7, 0.3] #Hard-coding for now
    return {dayNutrMin: dayNutrMin,
            dayNutrTarget: dayNutrTarget, 
            dayNutrMax: dayNutrMax, 
            mealNutrMin: mealNutrMin,
            mealNutrTarget: mealNutrTarget,
            mealNutrMax: mealNutrMax,
            nutrWeights: nutrWeights,
            dayAndMealWeights: dayAndMealWeights}
  end

  def preprocess_day_objects(daily_constraint_set_params)
    dayNutrMin = Array.new(NUTRIENTS.length, 0)
    dayNutrTarget = Array.new(NUTRIENTS.length, 0)
    dayNutrMax = Array.new(NUTRIENTS.length, 0)
    NUTRIENTS.each_with_index do |nutrient, idx|
      dayNutrMin[idx]= daily_constraint_set_params[ ('min_' << nutrient.to_s).to_sym ].to_f
      dayNutrTarget[idx]= daily_constraint_set_params[ ('target_' << nutrient.to_s).to_sym ].to_f
      dayNutrMax[idx]= daily_constraint_set_params[ ('max_' << nutrient.to_s).to_sym ].to_f
    end
    return dayNutrMin, dayNutrTarget, dayNutrMax
  end

  def preprocess_meal_objects(meal_constraint_sets_params)
    mealNutrMin = Array.new(NUTRIENTS.length) {Array.new(0)}
    mealNutrTarget = Array.new(NUTRIENTS.length) {Array.new(0)}
    mealNutrMax = Array.new(NUTRIENTS.length) {Array.new(0)}
    NUTRIENTS.each_with_index do |nutrient, idx|
      meal_constraint_sets_params.each do |meal_constraint_set|
        mealNutrMin[idx] << meal_constraint_set[ ('min_' << nutrient.to_s).to_sym ].to_f
        mealNutrTarget[idx] << meal_constraint_set[ ('target_' << nutrient.to_s).to_sym ].to_f
        mealNutrMax[idx] << meal_constraint_set[ ('max_' << nutrient.to_s).to_sym ].to_f
      end
    end
    return mealNutrMin, mealNutrTarget, mealNutrMax
  end

  ############# PREPROCESS NUTRITION INFO #############

  def preprocess_nutrition_info(sources_by_meals_params)
    srcPerMeal = sources_by_meals_params.inject([]) { |arr, sources_by_meal| arr << sources_by_meal[:foods_by_sources].length }
    foodsPerSrc = preprocess_foodsPerSrc(sources_by_meals_params)
    num_foods = foodsPerSrc.reduce(:+)
    foodCost ||= Array.new(num_foods,0)  # Hard-coded for now
    foodMin ||= Array.new(num_foods,0)  # Hard-coded for now
    foodMax ||= Array.new(num_foods,7) # Hard-coded for now
    nutrPer, food_indices_by_meal = getNutrPer_and_food_indices_by_meal(sources_by_meals_params, num_foods)
    foodAmounts = getFoodAmounts(sources_by_meals_params, food_indices_by_meal)
    return {  foodCost: foodCost, 
              foodMin: foodMin, 
              foodMax: foodMax,
              srcPerMeal: srcPerMeal, 
              foodsPerSrc: foodsPerSrc,
              nutrPer: nutrPer,
              foodAmounts: foodAmounts
            },
            food_indices_by_meal
  end

  def preprocess_foodsPerSrc(sources_by_meals_params)
    foodsPerSrc_unflattened = 
      sources_by_meals_params.inject([]) do |arr1, sources_by_meal| 
        arr1 << sources_by_meal[:foods_by_sources].inject([]) { 
          |arr2, foods_by_source| arr2 << getNumFoodsPerSource(foods_by_source) 
        }
      end
    foodsPerSrc = foodsPerSrc_unflattened.flatten
    return foodsPerSrc
  end

  def getNumFoodsPerSource(foods_by_source) 
    foods = get_foods_by_source_helper(foods_by_source)
    return foods.count
  end

  ######################################################
  # WORK ON THIS SECTION FOR FOOD SOURCE SELECTION!!!! #
  ######################################################
  def get_foods_by_source_helper(foods_by_source)
    foods = foods_by_source[:included_foods].present? ? 
      Food.find(foods_by_source[:included_foods].map {|x| x[:food_id]}) : 
      #Source.find(foods_by_source[:source_id]).foods
      # I'M THIS IS A TEMPORARY SOLUTION FOR HANDLING A DEFAULT VALUE OF 0 TO GET ALL REGULAR FOODS
      foods_by_source[:source_id].to_i == 1 ? 
          Food.where(type:['Recipe',nil]) : # TEMPORARY: THIS LINE ONLY EXCLUDES MENU ITEMS
        Source.find(foods_by_source[:source_id]).menu_items #TEMPORTARY: THIS LINE ASSUMES ANY INPUTED SOURCE IS A RESTAURANT
    foods = foods.where.not(id: foods_by_source[:excluded_foods].map {|x| x[:food_id]}) if foods_by_source[:excluded_foods].present?
    return foods
  end

  def getNutrPer_and_food_indices_by_meal(sources_by_meals_params, num_foods)
    num_Meals = sources_by_meals_params.length
    
    # Unflattened foods are needed for keeping track of which meal it belongs to
    unflattened_foods = getFoodsByMealAndSource(sources_by_meals_params)
    # These two are combined later in the same function to ensure position matches.
    nutrPer = preprocess_nutrPer(unflattened_foods, num_foods)
    food_indices_by_meal = preprocess_food_indices_by_meal(sources_by_meals_params, unflattened_foods)
    
    return nutrPer, food_indices_by_meal
  end

  def preprocess_nutrPer(unflattened_foods, num_foods)
    nutrPer = Array.new(NUTRIENTS.length) {Array.new(num_foods,0)}
    # Flatten to iterate over the array for creating nutrPer
    flattened_foods = unflattened_foods.flatten
    NUTRIENTS.each_with_index do |nutrient, idx1|
      flattened_foods.each_with_index do |food, idx2|
        nutrPer[idx1][idx2] = food.send(nutrient).to_f
      end
    end
    return nutrPer
  end

  def preprocess_food_indices_by_meal(sources_by_meals_params, unflattened_foods)
    food_indices_by_meal = Array.new(sources_by_meals_params.length) {Array.new(0)}
    unflattened_foods.each_with_index do |foods_by_meal, idx|
      food_indices_by_meal[idx] = foods_by_meal.flatten.map { |x| x.id }
    end
    return food_indices_by_meal
  end

  def getFoodAmounts(sources_by_meals_params, food_indices_by_meal)
    foodAmountsInMeals = get_food_amounts_in_meals_helper(sources_by_meals_params)
    foodAmounts = get_food_amounts_helper(food_indices_by_meal, foodAmountsInMeals)
    return foodAmounts
  end

  def get_food_amounts_in_meals_helper(sources_by_meals_params)
    foodAmountsInMeals = []
    sources_by_meals_params.each_with_index do |meal_params, idx|
      # There should only be one source per meal if there's fixed amounts.  Otherwise, this should error out.
      foodAmountsInMeal = []
      meal_params[:foods_by_sources].each do |source_params|
        foodAmountsInMeal.push(source_params[:included_food_amounts])
      end
      foodAmountsInMeals.push(foodAmountsInMeal.flatten)
    end
    return foodAmountsInMeals
  end

  def get_food_amounts_helper(food_indices_by_meal, foodAmountsInMeals)
    foodAmounts = []
    food_indices_by_meal.each_with_index do |foods_indices_in_meal, idx|
      foods_indices_in_meal.each do |foodId|
        id = foodAmountsInMeals[idx].find_index {|item| item[:food_id] == foodId}
        amount = id ? foodAmountsInMeals[idx][id][:amount].to_i : -1
        foodAmounts.push(amount)
      end
    end
    return foodAmounts
  end

  # THIS COULD BE COMBINE WITH getNumFoodsPerSource() TO ELIMINATE THE SECOND DATABASE FETCH
  def getFoodsByMealAndSource(sources_by_meals_params)
    foodsByMealAndSource = Array.new(sources_by_meals_params.length)
    sources_by_meals_params.each_with_index do |meal, idx1|
      foodsByMealAndSource[idx1] = Array.new(sources_by_meals_params[idx1][:foods_by_sources].length)
      sources_by_meals_params[idx1][:foods_by_sources].each_with_index do |foods_by_source, idx2|
        foods = get_foods_by_source_helper(foods_by_source)
        foodsByMealAndSource[idx1][idx2] = foods
      end
    end
    return foodsByMealAndSource
  end

  ############# I/O - Write #############

  def save_data_to_file(preprocessed_constraints, preprocessed_nutrition_info)
    data = createDataFile(preprocessed_constraints, preprocessed_nutrition_info)
    writeFile(data)
  end

  def createDataFile(preprocessed_constraints, preprocessed_nutrition_info)
    data = ''
    data << preprocessed_nutrition_info[:foodCost].to_s << "\n"
    data << preprocessed_nutrition_info[:foodMin].to_s << "\n"
    data << preprocessed_nutrition_info[:foodMax].to_s << "\n"
    data << preprocessed_constraints[:dayNutrMin].to_s << "\n"
    data << preprocessed_constraints[:dayNutrMax].to_s << "\n"
    data << preprocessed_nutrition_info[:nutrPer].to_s << "\n"
    data << preprocessed_nutrition_info[:srcPerMeal].to_s << "\n"
    data << preprocessed_nutrition_info[:foodsPerSrc].to_s << "\n"
    data << preprocessed_nutrition_info[:foodAmounts].to_s << "\n"
    data << preprocessed_constraints[:dayNutrTarget].to_s << "\n"
    data << preprocessed_constraints[:mealNutrMin].to_s << "\n"
    data << preprocessed_constraints[:mealNutrMax].to_s << "\n"
    data << preprocessed_constraints[:mealNutrTarget].to_s << "\n"
    data << preprocessed_constraints[:nutrWeights].to_s << "\n"
    data << preprocessed_constraints[:dayAndMealWeights].to_s << "\n"
    return data
  end
  
  def writeFile(data)
    File.open("cplex/data/meal_plan.dat", 'w') do |f|
      f.write(data)
    end
  end

    
  ############# OPTIMIZE #############

  def call_optimization()
    application_path = Dir.home << "/Applications/IBM/ILOG/CPLEX_Studio1263/cplex/examples/x86-64_osx/static_pic/meal_plan"
    data_root = Dir.home << "/Desktop/mnutritionserver"
    result = system(application_path << " -i " << data_root << "/cplex/data/meal_plan.dat")
  end

  ############# I/O - Read #############

  def read_results()
    # Wrap results string in an array
    # There's actually only one line right now
    results = []
    File.open("cplex/meal_plan_results.txt", 'r') do |f|
      f.each_line do |line|
        results << line.split(",").map(&:to_f) 
      end
    end
    results = results.flatten # Equivalent to flatten(1)
    return results
  end

  ############# RETURN MEAL PLAN #############

  # TODO: ENSURE CORRECT DATE BY PASSING IT IN
  def convert_results_to_new_meal_plan(results, food_indices_by_meal, sources_by_meals_params)
    @date = Date.today # FIX !!!!!!!
    # results file is flattened, so must keep a count
    @meal_plan = current_user.meal_plans.build(used_at: @date)
    results_cnt = 0
    food_indices_by_meal.each_with_index do |foods_in_meal, idx|
      # Meal title is not passed in from http as of now.
      meal = sources_by_meals_params.find {|obj| obj[:position] == idx+1}
      id = meal[:position]
      position = meal[:position]
      title = meal[:title]
      meal_plan_id = meal[:meal_plan_id]
      @meal = @meal_plan.meals.build(user_id: current_user.id, position: position, title: title, used_at: @date)  
      foods_in_meal.each do |food_index|
        @meal.meal_items.build(amount: results[results_cnt].to_f.round, food_id: food_index) if results[results_cnt].to_f > 0.01 # I'm using 0.1 instead of 0 to handle errors due to optimization
        results_cnt += 1
      end
      @meal.update_nutrients
    end
    @meal_plan.update_nutrients
    return @meal_plan
  end

end