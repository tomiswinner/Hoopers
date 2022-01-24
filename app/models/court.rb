class Court < ApplicationRecord
  belongs_to :user
  belongs_to :area

  has_many :events,             dependent: :destroy
  has_many :court_reviews,      dependent: :destroy
  has_many :court_favorites,    dependent: :destroy
  has_many :court_histories,    dependent: :destroy
  has_many :court_tag_taggings, dependent: :destroy

  def fetch_pref_name
    return Prefecture.find(Area.find(area_id).prefecture_id).name
  end
end
