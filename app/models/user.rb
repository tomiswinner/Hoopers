class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :courts,           dependent: :restrict_with_exception
  has_many :court_reviews,    dependent: :destroy
  has_many :court_histories,  dependent: :destroy
  has_many :court_favorites,  dependent: :destroy
  has_many :events,           dependent: :destroy
  has_many :event_histories,  dependent: :destroy
  has_many :event_favorites,  dependent: :destroy
  has_many :court_infos,      dependent: :destroy

  def active_for_authentication?
    super && is_active
  end

  def favorites_this_court?(court_id)
    return true if court_favorites.find_by(court_id: court_id)

    return false
  end

  def favorites_this_event?(event_id)
    return true if event_favorites.find_by(event_id: event_id)

    return false
  end

  def reviewed_this_court?(court_id)
    return true if court_reviews.find_by(court_id: court_id)

    return false
  end

  def history_exists?(model)
    case model.class.name
    when 'Court'
      return CourtHistory.where(user_id: id, court_id: model.id).count != 0
    when 'Event'
      return EventHistory.where(user_id: id, event_id: model.id).count != 0
    end
  end

  def histories_reached_to_limit?(model)
    case model.class.name
    when 'Court'
      return CourtHistory.where(user_id: id).count > 10
    when 'Event'
      return EventHistory.where(user_id: id).count > 10
    end
  end
end
