require 'rails_helper'

RSpec.describe Recipe, type: :model do
  let(:recipe) { FactoryGirl.build :recipe }
  subject {  recipe }

  it { is_expected.to respond_to(:title) }
  it { is_expected.to respond_to(:published_at) }
  it { is_expected.to respond_to(:user_id) }
  it { is_expected.to respond_to(:calories) }
  it { is_expected.to respond_to(:fat) }
  it { is_expected.to respond_to(:carbohydrates) }
  it { is_expected.to respond_to(:protein) }

  it { is_expected.not_to be_published_at }

  it { is_expected.to belong_to :user }

  it { is_expected.to have_many(:ingredients) }
  it { is_expected.to have_many(:foods).through(:ingredients) }

  before(:each) do
    @user = FactoryGirl.create :user
    @food1 = FactoryGirl.create :food, {title: 'food1', calories: 100, fat: 100, carbohydrates: 100, protein: 100}
    @food2 = FactoryGirl.create :food, {title: 'food2',calories: 50,fat: 50, carbohydrates: 50, protein: 50}
    @food3 = FactoryGirl.create :food, {title: 'food3',calories: 150, fat: 150, carbohydrates: 150, protein: 150}
    @food4 = FactoryGirl.create :food, {title: 'food4',calories: 99, fat: 99, carbohydrates: 99, protein: 99}
    @recipe1 = Recipe.create(user_id: @user.id, title: "Tuesday Lunch")
    @recipe2 = Recipe.create(user_id: @user.id, title: "Breakfast")
    @recipe3 = Recipe.create(user_id: @user.id, title: "Dinner")
    @recipe4 = Recipe.create(user_id: @user.id, title: "Monday Lunch")
    @ingredient1 = Ingredient.create(recipe_id: @recipe1.id, food_id: @food1.id, amount:1)
    @ingredient2 = Ingredient.create(recipe_id: @recipe2.id, food_id: @food2.id, amount:1)
    @ingredient3 = Ingredient.create(recipe_id: @recipe3.id, food_id: @food3.id, amount:1)
    @ingredient4 = Ingredient.create(recipe_id: @recipe4.id, food_id: @food4.id, amount:1)
  end

  describe ".filter_by_title" do
    context "when a 'Lunch' title pattern is sent" do
      it "returns the 2 recipes matching" do
        expect(Recipe.filter_by_title('Lunch').size).to eq(2)
      end

      it "returns the recipes matching" do
        expect(Recipe.filter_by_title("Lunch").sort).to match_array([@recipe1, @recipe4])
      end
    end
  end

  describe 'Filter .by_above_or_equal_to_calories' do
    it 'returns the recipes which are above or equal to the calories' do
      expect(Recipe.by_above_or_equal_to_calories(100).sort).to match_array([@recipe1, @recipe3])
    end
  end

  describe 'Filter .by_below_or_equal_to_calories' do
    it 'returns the recipes which are below or equal to the calories' do
      expect(Recipe.by_below_or_equal_to_calories(99).sort).to match_array([@recipe2, @recipe4])
    end
  end

  describe 'Filter .by_above_or_equal_to_fat' do
    it 'returns the recipes which are above or equal to the fat' do
      expect(Recipe.by_above_or_equal_to_fat(100).sort).to match_array([@recipe1, @recipe3])
    end
  end

  describe 'Filter .by_below_or_equal_to_fat' do
    it 'returns the recipes which are below or equal to the fat' do
      expect(Recipe.by_below_or_equal_to_fat(99).sort).to match_array([@recipe2, @recipe4])
    end
  end

  describe 'Filter .by_above_or_equal_to_carbohydrates' do
    it 'returns the recipes which are above or equal to the carbohydrates' do
      expect(Recipe.by_above_or_equal_to_carbohydrates(100).sort).to match_array([@recipe1, @recipe3])
    end
  end

  describe 'Filter .by_below_or_equal_to_carbohydrates' do
    it 'returns the recipes which are below or equal to the carbohydrates' do
      expect(Recipe.by_below_or_equal_to_carbohydrates(99).sort).to match_array([@recipe2, @recipe4])
    end
  end

  describe 'Filter .by_above_or_equal_to_protein' do
    it 'returns the recipes which are above or equal to the protein' do
      expect(Recipe.by_above_or_equal_to_protein(100).sort).to match_array([@recipe1, @recipe3])
    end
  end

  describe 'Filter .by_below_or_equal_to_protein' do
    it 'returns the recipes which are below or equal to the protein' do
      expect(Recipe.by_below_or_equal_to_protein(99).sort).to match_array([@recipe2, @recipe4])
    end
  end

  describe 'Filter .by_recently_updated' do
    before(:each) do
      # Touch some recipes to update them
      @recipe2.touch
      @recipe3.touch
    end

    it 'returns the most updated records' do
      expect(Recipe.by_recently_updated).to match_array([@recipe3, @recipe2, @recipe4, @recipe1])
    end
  end

  describe '.search' do
    context "when title 'Breakfast' and '100' a min calories are set" do
      it 'returns an empty array' do
        search_hash = { keyword: 'Breakfast', min_calories: 100 }
        expect(Recipe.search(search_hash)).to be_empty
      end
    end

    context "when title 'Monday', '150' as max calories, and '50' as min calories are set" do
      it 'returns the @recipe1' do
        search_hash = { keyword: 'Lunch', min_calories: 50, max_calories: 150 }
        expect(Recipe.search(search_hash)).to match_array([@recipe1, @recipe4]) 
      end
    end

    context 'when an empty hash is sent' do
      it 'returns all the recipes' do
        expect(Recipe.search({})).to match_array([@recipe1, @recipe2, @recipe3, @recipe4])
      end
    end

    context 'when recipe_ids is present' do
      it 'returns the recipe from the ids' do
        search_hash = { recipe_ids: [@recipe1.id, @recipe2.id]}
        expect(Recipe.search(search_hash)).to match_array([@recipe1, @recipe2])
      end
    end
  end

  describe 'Filter by Ingredients ' do
    it 'excludes 1 id' do
      search_hash = { excluded_food_ids: [@food1.id] }
      expect(Recipe.search(search_hash)).to match_array([@recipe2, @recipe3, @recipe4])
    end
    it 'excludes multiple ids' do
      search_hash = { excluded_food_ids: [@food2.id, @food3.id] }
      expect(Recipe.search(search_hash)).to match_array([@recipe1, @recipe4])
    end
  end
end
