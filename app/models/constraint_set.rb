class ConstraintSet < ApplicationRecord
  belongs_to :user

  validates :min_calories, numericality: { greater_than_or_equal_to: 0 }, presence: true
  validates :target_calories, numericality: { greater_than_or_equal_to: 0 }, presence: true
  validates :max_calories, numericality: { greater_than_or_equal_to: 0 }, presence: true
  validates :min_fat, numericality: { greater_than_or_equal_to: 0 }, presence: true
  validates :target_fat, numericality: { greater_than_or_equal_to: 0 }, presence: true
  validates :max_fat, numericality: { greater_than_or_equal_to: 0 }, presence: true
  validates :min_carbohydrates, numericality: { greater_than_or_equal_to: 0 }, presence: true
  validates :target_carbohydrates, numericality: { greater_than_or_equal_to: 0 }, presence: true
  validates :max_carbohydrates, numericality: { greater_than_or_equal_to: 0 }, presence: true
  validates :min_protein, numericality: { greater_than_or_equal_to: 0 }, presence: true
  validates :target_protein, numericality: { greater_than_or_equal_to: 0 }, presence: true
  validates :max_protein, numericality: { greater_than_or_equal_to: 0 }, presence: true
end
