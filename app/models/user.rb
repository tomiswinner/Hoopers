class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :courts,           dependent: :destroy
  has_many :court_reviews,    dependent: :destroy
  has_many :court_histories,  dependent: :destroy
  has_many :court_favorites,  dependent: :destroy
  has_many :events,           dependent: :destroy
  has_many :event_histories,  dependent: :destroy
  has_many :event_favorites,  dependent: :destroy

  def active_for_authentication?
    super && is_active
  end

  def favorites_this_court?(court_id)
    if  court_favorites.find_by(court_id: court_id)
      return true
    else
      return false
    end
  end

  def favorites_this_event?(event_id)
    if  event_favorites.find_by(event_id: event_id)
      return true
    else
      return false
    end
  end

  def reviewed_this_court?(court_id)
    if  court_reviews.find_by(court_id: court_id)
      return true
    else
      return false
    end
  end
end
