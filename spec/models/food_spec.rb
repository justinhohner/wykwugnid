require 'rails_helper'

RSpec.describe Food, type: :model do
  let(:food) { FactoryGirl.build :food }
  subject {  food }

  it { is_expected.to respond_to(:title) }
  it { is_expected.to respond_to(:calories) }
  it { is_expected.to respond_to(:fat) }
  it { is_expected.to respond_to(:carbohydrates) }
  it { is_expected.to respond_to(:protein) }

  it { is_expected.to have_many(:pantry_items) }
  it { is_expected.to have_many(:pantries).through(:pantry_items) }
  it { is_expected.to have_many(:ingredients) }
  it { is_expected.to have_many(:recipes).through(:ingredients) }

  before(:each) do
    @food1 = FactoryGirl.create :food, {title: "Apple Pie", 
                                        calories: 100, 
                                        fat: 100, 
                                        carbohydrates: 100, 
                                        protein: 100
                                        }
    @food2 = FactoryGirl.create :food, {title: "Steak", 
                                        calories: 50,
                                        fat: 50, 
                                        carbohydrates: 50, 
                                        protein: 50
                                        }
    @food3 = FactoryGirl.create :food, {title: "Ice Cream", 
                                        calories: 150,
                                        fat: 150, 
                                        carbohydrates: 150, 
                                        protein: 150
                                        }
    @food4 = FactoryGirl.create :food, {title: "Carrot Pie", 
                                        calories: 99,
                                        fat: 99, 
                                        carbohydrates: 99, 
                                        protein: 99
                                        }
  end

  describe ".filter_by_title" do
    context "when a 'Pie' title pattern is sent" do
      it "returns the 2 foods matching" do
        expect(Food.filter_by_title('Pie').size).to eq(2)
      end

      it "returns the foods matching" do
        expect(Food.filter_by_title("Pie").sort).to match_array([@food1, @food4])
      end
    end
  end

  describe 'Filter .by_above_or_equal_to_calories' do
    it 'returns the foods which are above or equal to the calories' do
      expect(Food.by_above_or_equal_to_calories(100).sort).to match_array([@food1, @food3])
    end
  end

  describe 'Filter .by_below_or_equal_to_calories' do
    it 'returns the foods which are below or equal to the calories' do
      expect(Food.by_below_or_equal_to_calories(99).sort).to match_array([@food2, @food4])
    end
  end

  describe 'Filter .by_above_or_equal_to_fat' do
    it 'returns the foods which are above or equal to the fat' do
      expect(Food.by_above_or_equal_to_fat(100).sort).to match_array([@food1, @food3])
    end
  end

  describe 'Filter .by_below_or_equal_to_fat' do
    it 'returns the foods which are below or equal to the fat' do
      expect(Food.by_below_or_equal_to_fat(99).sort).to match_array([@food2, @food4])
    end
  end

  describe 'Filter .by_above_or_equal_to_carbohydrates' do
    it 'returns the foods which are above or equal to the carbohydrates' do
      expect(Food.by_above_or_equal_to_carbohydrates(100).sort).to match_array([@food1, @food3])
    end
  end

  describe 'Filter .by_below_or_equal_to_carbohydrates' do
    it 'returns the foods which are below or equal to the carbohydrates' do
      expect(Food.by_below_or_equal_to_carbohydrates(99).sort).to match_array([@food2, @food4])
    end
  end

  describe 'Filter .by_above_or_equal_to_protein' do
    it 'returns the foods which are above or equal to the protein' do
      expect(Food.by_above_or_equal_to_protein(100).sort).to match_array([@food1, @food3])
    end
  end

  describe 'Filter .by_below_or_equal_to_protein' do
    it 'returns the foods which are below or equal to the protein' do
      expect(Food.by_below_or_equal_to_protein(99).sort).to match_array([@food2, @food4])
    end
  end

  describe 'Filter .by_recently_updated' do
    before(:each) do
      # Touch some foods to update them
      @food2.touch
      @food3.touch
    end

    it 'returns the most updated records' do
      expect(Food.by_recently_updated).to match_array([@food3, @food2, @food4, @food1])
    end
  end

  describe '.search' do
    context "when title 'Steak' and '100' a min calories are set" do
      it 'returns an empty array' do
        search_hash = { keyword: 'Steak', min_calories: 100 }
        expect(Food.search(search_hash)).to be_empty
      end
    end

    context "when title 'Carrot', '150' as max calories, and '50' as min calories are set" do
      it 'returns the @food1' do
        search_hash = { keyword: 'Pie', min_calories: 50, max_calories: 150 }
        expect(Food.search(search_hash)).to match_array([@food1, @food4]) 
      end
    end

    context 'when an empty hash is sent' do
      it 'returns all the foods' do
        expect(Food.search({})).to match_array([@food1, @food2, @food3, @food4])
      end
    end

    context 'when food_ids is present' do
      it 'returns the food from the ids' do
        search_hash = { food_ids: [@food1.id, @food2.id]}
        expect(Food.search(search_hash)).to match_array([@food1, @food2])
      end
    end
  end
end
