require 'rails_helper'

RSpec.describe MenuItem, type: :model do
  let(:menu_item) { FactoryGirl.build :menu_item }
  subject {  menu_item }

  it { is_expected.to respond_to(:title) }
  it { is_expected.to respond_to(:published_at) }
  it { is_expected.to respond_to(:calories) }
  it { is_expected.to respond_to(:fat) }
  it { is_expected.to respond_to(:carbohydrates) }
  it { is_expected.to respond_to(:protein) }
  it { is_expected.to respond_to(:price) }

  it { is_expected.not_to be_published_at }
  
  it { is_expected.to have_many(:menu_item_ingredients) }
  it { is_expected.to have_many(:foods).through(:menu_item_ingredients) }
  it { is_expected.to have_many(:menu_join_menu_items) }
  it { is_expected.to have_many(:menus).through(:menu_join_menu_items) }
  it { is_expected.to have_one(:restaurant_join_menu_item) }
  it { is_expected.to have_one(:restaurant).through(:restaurant_join_menu_item) }

  before(:each) do
    @menu_item1 = FactoryGirl.create :menu_item, {title: "Tuesday Lunch", 
                                        calories: 100, 
                                        fat: 100, 
                                        carbohydrates: 100, 
                                        protein: 100,
                                        price: 1
                                        }
    @menu_item2 = FactoryGirl.create :menu_item, {title: "Breakfast", 
                                        calories: 50,
                                        fat: 50, 
                                        carbohydrates: 50, 
                                        protein: 50,
                                        price: 1
                                        }
    @menu_item3 = FactoryGirl.create :menu_item, {title: "Dinner", 
                                        calories: 150,
                                        fat: 150, 
                                        carbohydrates: 150, 
                                        protein: 150,
                                        price: 1
                                        }
    @menu_item4 = FactoryGirl.create :menu_item, {title: "Monday Lunch", 
                                        calories: 99,
                                        fat: 99, 
                                        carbohydrates: 99, 
                                        protein: 99,
                                        price: 1
                                        }
  end

  describe ".filter_by_title" do
    context "when a 'Lunch' title pattern is sent" do
      it "returns the 2 menu_items matching" do
        expect(MenuItem.filter_by_title('Lunch').size).to eq(2)
      end

      it "returns the menu_items matching" do
        expect(MenuItem.filter_by_title("Lunch").sort).to match_array([@menu_item1, @menu_item4])
      end
    end
  end

  # describe 'Filter .by_above_or_equal_to_calories' do
  #   it 'returns the menu_items which are above or equal to the calories' do
  #     expect(MenuItem.by_above_or_equal_to_calories(100).sort).to match_array([@menu_item1, @menu_item3])
  #   end
  # end

  # describe 'Filter .by_below_or_equal_to_calories' do
  #   it 'returns the menu_items which are below or equal to the calories' do
  #     expect(MenuItem.by_below_or_equal_to_calories(99).sort).to match_array([@menu_item2, @menu_item4])
  #   end
  # end

  # describe 'Filter .by_above_or_equal_to_fat' do
  #   it 'returns the menu_items which are above or equal to the fat' do
  #     expect(MenuItem.by_above_or_equal_to_fat(100).sort).to match_array([@menu_item1, @menu_item3])
  #   end
  # end

  # describe 'Filter .by_below_or_equal_to_fat' do
  #   it 'returns the menu_items which are below or equal to the fat' do
  #     expect(MenuItem.by_below_or_equal_to_fat(99).sort).to match_array([@menu_item2, @menu_item4])
  #   end
  # end

  # describe 'Filter .by_above_or_equal_to_carbohydrates' do
  #   it 'returns the menu_items which are above or equal to the carbohydrates' do
  #     expect(MenuItem.by_above_or_equal_to_carbohydrates(100).sort).to match_array([@menu_item1, @menu_item3])
  #   end
  # end

  # describe 'Filter .by_below_or_equal_to_carbohydrates' do
  #   it 'returns the menu_items which are below or equal to the carbohydrates' do
  #     expect(MenuItem.by_below_or_equal_to_carbohydrates(99).sort).to match_array([@menu_item2, @menu_item4])
  #   end
  # end

  # describe 'Filter .by_above_or_equal_to_protein' do
  #   it 'returns the menu_items which are above or equal to the protein' do
  #     expect(MenuItem.by_above_or_equal_to_protein(100).sort).to match_array([@menu_item1, @menu_item3])
  #   end
  # end

  # describe 'Filter .by_below_or_equal_to_protein' do
  #   it 'returns the menu_items which are below or equal to the protein' do
  #     expect(MenuItem.by_below_or_equal_to_protein(99).sort).to match_array([@menu_item2, @menu_item4])
  #   end
  # end

  # describe 'Filter .by_recently_updated' do
  #   before(:each) do
  #     # Touch some menu_items to update them
  #     @menu_item2.touch
  #     @menu_item3.touch
  #   end

  #   it 'returns the most updated records' do
  #     expect(MenuItem.by_recently_updated).to match_array([@menu_item3, @menu_item2, @menu_item4, @menu_item1])
  #   end
  # end

  # describe '.search' do
  #   context "when title 'Breakfast' and '100' a min calories are set" do
  #     it 'returns an empty array' do
  #       search_hash = { keyword: 'Breakfast', min_calories: 100 }
  #       expect(MenuItem.search(search_hash)).to be_empty
  #     end
  #   end

  #   context "when title 'Monday', '150' as max calories, and '50' as min calories are set" do
  #     it 'returns the @menu_item1' do
  #       search_hash = { keyword: 'Lunch', min_calories: 50, max_calories: 150 }
  #       expect(MenuItem.search(search_hash)).to match_array([@menu_item1, @menu_item4]) 
  #     end
  #   end

  #   context 'when an empty hash is sent' do
  #     it 'returns all the menu_items' do
  #       expect(MenuItem.search({})).to match_array([@menu_item1, @menu_item2, @menu_item3, @menu_item4])
  #     end
  #   end

  #   context 'when menu_item_ids is present' do
  #     it 'returns the menu_item from the ids' do
  #       search_hash = { menu_item_ids: [@menu_item1.id, @menu_item2.id]}
  #       expect(MenuItem.search(search_hash)).to match_array([@menu_item1, @menu_item2])
  #     end
  #   end
  # end
end
