class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :courts,           dependent: :destroy
  has_many :event_reviews,    dependent: :destroy
  has_many :court_histories,  dependent: :destroy
  has_many :court_favorites,  dependent: :destroy
  has_many :events,           dependent: :destroy
  has_many :event_histories,  dependent: :destroy
  has_many :event_favorites,  dependent: :destroy
end
