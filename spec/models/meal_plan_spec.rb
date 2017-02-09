require 'rails_helper'

RSpec.describe MealPlan, type: :model do
  let(:meal_plan) { FactoryGirl.build :meal_plan }
  subject {  meal_plan }

  it { is_expected.to respond_to(:title) }
  it { is_expected.to respond_to(:published_at) }
  it { is_expected.to respond_to(:user_id) }
  it { is_expected.to respond_to(:calories) }
  it { is_expected.to respond_to(:fat) }
  it { is_expected.to respond_to(:carbohydrates) }
  it { is_expected.to respond_to(:protein) }

  it { is_expected.not_to be_published_at }

  it { is_expected.to belong_to :user }

  before(:each) do
    @user = FactoryGirl.create :user
    @meal_plan1 = MealPlan.create(user_id:@user.id, title: "Tuesday Lunch")
    @meal_plan2 = MealPlan.create(user_id:@user.id, title: "Breakfast")
    @meal_plan3 = MealPlan.create(user_id:@user.id, title: "Dinner")
    @meal_plan4 = MealPlan.create(user_id:@user.id, title: "Monday Lunch")

    @food1 = FactoryGirl.create :food, {title: 'food1', calories: 100, fat: 100, carbohydrates: 100, protein: 100}
    @food2 = FactoryGirl.create :food, {title: 'food2',calories: 50,fat: 50, carbohydrates: 50, protein: 50}
    @food3 = FactoryGirl.create :food, {title: 'food3',calories: 150, fat: 150, carbohydrates: 150, protein: 150}
    @food4 = FactoryGirl.create :food, {title: 'food4',calories: 99, fat: 99, carbohydrates: 99, protein: 99}
    @meal1 = Meal.create(user_id: @user.id, title: "Tuesday Lunch", meal_plan_id: @meal_plan1.id)
    @meal2 = Meal.create(user_id: @user.id, title: "Breakfast", meal_plan_id: @meal_plan2.id)
    @meal3 = Meal.create(user_id: @user.id, title: "Dinner", meal_plan_id: @meal_plan3.id)
    @meal4 = Meal.create(user_id: @user.id, title: "Monday Lunch", meal_plan_id: @meal_plan4.id)
    @meal_item1 = MealItem.create(meal_id: @meal1.id, food_id: @food1.id, amount:1)
    @meal_item2 = MealItem.create(meal_id: @meal2.id, food_id: @food2.id, amount:1)
    @meal_item3 = MealItem.create(meal_id: @meal3.id, food_id: @food3.id, amount:1)
    @meal_item4 = MealItem.create(meal_id: @meal4.id, food_id: @food4.id, amount:1)
  end

  describe ".filter_by_title" do
    context "when a 'Lunch' title pattern is sent" do
      it "returns the 2 meal_plans matching" do
        expect(MealPlan.filter_by_title('Lunch').size).to eq(2)
      end

      it "returns the meal_plans matching" do
        expect(MealPlan.filter_by_title("Lunch").sort).to match_array([@meal_plan1, @meal_plan4])
      end
    end
  end

  describe 'Filter .by_above_or_equal_to_calories' do
    it 'returns the meal_plans which are above or equal to the calories' do
      expect(MealPlan.by_above_or_equal_to_calories(100).sort).to match_array([@meal_plan1, @meal_plan3])
    end
  end

  describe 'Filter .by_below_or_equal_to_calories' do
    it 'returns the meal_plans which are below or equal to the calories' do
      expect(MealPlan.by_below_or_equal_to_calories(99).sort).to match_array([@meal_plan2, @meal_plan4])
    end
  end

  describe 'Filter .by_above_or_equal_to_fat' do
    it 'returns the meal_plans which are above or equal to the fat' do
      expect(MealPlan.by_above_or_equal_to_fat(100).sort).to match_array([@meal_plan1, @meal_plan3])
    end
  end

  describe 'Filter .by_below_or_equal_to_fat' do
    it 'returns the meal_plans which are below or equal to the fat' do
      expect(MealPlan.by_below_or_equal_to_fat(99).sort).to match_array([@meal_plan2, @meal_plan4])
    end
  end

  describe 'Filter .by_above_or_equal_to_carbohydrates' do
    it 'returns the meal_plans which are above or equal to the carbohydrates' do
      expect(MealPlan.by_above_or_equal_to_carbohydrates(100).sort).to match_array([@meal_plan1, @meal_plan3])
    end
  end

  describe 'Filter .by_below_or_equal_to_carbohydrates' do
    it 'returns the meal_plans which are below or equal to the carbohydrates' do
      expect(MealPlan.by_below_or_equal_to_carbohydrates(99).sort).to match_array([@meal_plan2, @meal_plan4])
    end
  end

  describe 'Filter .by_above_or_equal_to_protein' do
    it 'returns the meal_plans which are above or equal to the protein' do
      expect(MealPlan.by_above_or_equal_to_protein(100).sort).to match_array([@meal_plan1, @meal_plan3])
    end
  end

  describe 'Filter .by_below_or_equal_to_protein' do
    it 'returns the meal_plans which are below or equal to the protein' do
      expect(MealPlan.by_below_or_equal_to_protein(99).sort).to match_array([@meal_plan2, @meal_plan4])
    end
  end

  describe 'Filter .by_recently_updated' do
    before(:each) do
      # Touch some meal_plans to update them
      @meal_plan2.touch
      @meal_plan3.touch
    end

    it 'returns the most updated records' do
      expect(MealPlan.by_recently_updated).to match_array([@meal_plan3, @meal_plan2, @meal_plan4, @meal_plan1])
    end
  end

  describe '.search' do
    context "when title 'Breakfast' and '100' a min calories are set" do
      it 'returns an empty array' do
        search_hash = { keyword: 'Breakfast', min_calories: 100 }
        expect(MealPlan.search(search_hash)).to be_empty
      end
    end

    context "when title 'Monday', '150' as max calories, and '50' as min calories are set" do
      it 'returns the @meal_plan1' do
        search_hash = { keyword: 'Lunch', min_calories: 50, max_calories: 150 }
        expect(MealPlan.search(search_hash)).to match_array([@meal_plan1, @meal_plan4]) 
      end
    end

    context 'when an empty hash is sent' do
      it 'returns all the meal_plans' do
        expect(MealPlan.search({})).to match_array([@meal_plan1, @meal_plan2, @meal_plan3, @meal_plan4])
      end
    end

    context 'when meal_plan_ids is present' do
      it 'returns the meal_plan from the ids' do
        search_hash = { meal_plan_ids: [@meal_plan1.id, @meal_plan2.id]}
        expect(MealPlan.search(search_hash)).to match_array([@meal_plan1, @meal_plan2])
      end
    end
  end
end
