class Court < ApplicationRecord
  attachment :image

  belongs_to :user
  belongs_to :area

  has_many :events,             dependent: :destroy
  has_many :court_reviews,      dependent: :destroy
  has_many :court_favorites,    dependent: :destroy
  has_many :court_histories,    dependent: :destroy
  has_many :court_tag_taggings, dependent: :destroy


  enum court_type: {体育館: 0, アスファルト: 1, ゴム: 2, 砂: 3, その他: 4, 確認中: 5}

  def fetch_pref_name
    return Prefecture.find(Area.find(area_id).prefecture_id).name
  end

  def self.convert_time_to_past_sec(hours, mins)
    hours_sec = hours.to_i * 60 * 60
    mins_sec = mins.to_i * 60
    return hours_sec + mins_sec
  end

  def convert_open_time_to_hour_min
    return (Time.now.midnight + open_time).strftime("%H:%M")
  end

  def convert_close_time_to_hour_min
    return (Time.now.midnight + close_time).strftime("%H:%M")
  end

  def return_business_hour
    return convert_open_time_to_hour_min + " ～ " + convert_close_time_to_hour_min
  end

  def fetch_tags
    tags = Tag.none
    CourtTagTagging.where(court_id: id).pluck(:tag_id).each do |tag_id|
      tags += Tag.where(id: tag_id)
    end
    return tags
  end

  def average_court_total_reviews
    return court_reviews.pluck(:total_points).sum.fdiv(court_reviews.count)
  end
end
