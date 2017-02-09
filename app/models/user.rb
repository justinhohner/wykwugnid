class User < ApplicationRecord
  before_create :generate_authentication_token! # Should this be before_validation?
  after_create :initalize_pantry
  after_create :initalize_shopping_list

  validates :auth_token, uniqueness: true
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :meal_plans, dependent: :destroy
  has_many :meals, dependent: :destroy
  has_many :recipes, dependent: :destroy
  has_one  :pantry, dependent: :destroy
  has_one  :shopping_list, dependent: :destroy
  has_many :daily_constraint_sets, dependent: :destroy
  has_many :meal_constraint_sets, dependent: :destroy
  has_many :sources, through: :user_join_sources, dependent: :destroy
  has_many :user_join_sources, dependent: :destroy

  scope :filter_by_email, ->(email) { where(email: email.downcase) }

  def self.search(params = {})
    users = params[:user_ids].present? ? User.where(id: params[:user_ids].split(',')) : User.all 
    users = users.filter_by_email(params[:email]) if params[:email] # This needs to be sanitized
    users
  end
        
  def generate_authentication_token!
    begin
      self.auth_token = Devise.friendly_token
    end while self.class.exists?(auth_token: auth_token)
  end

  def initalize_pantry
    Pantry.create(user_id: self.id)
  end
  def initalize_shopping_list
    ShoppingList.create(user_id: self.id)
  end
  def initalize_favorites
    self.sources.create(title: 'My Foods')
    # self.sources.create(title: 'My Meals')
    # self.sources.create(title: 'My Meal Plans')
    self.sources.create(title: 'My Menu Items')
    self.sources.create(title: 'My Recipes')
    # Personal
    self.sources.create(title: 'Breakfast Items', personal: true)
  end

end
