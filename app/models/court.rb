
class Court < ApplicationRecord
  attachment :image

  belongs_to :user
  belongs_to :area

  has_many :events,             dependent: :destroy
  has_many :court_reviews,      dependent: :destroy
  has_many :court_favorites,    dependent: :destroy
  has_many :court_histories,    dependent: :destroy
  has_many :court_tag_taggings, dependent: :destroy

  validates :name                 ,presence: true
  validates :user_id              ,presence: true
  validates :area_id              ,presence: true
  validates :latitude             ,presence: true
  validates :longitude            ,presence: true
  validates :url                  ,presence: true
  validates :address              ,presence: true
  validates :supplement           ,presence: true
  validates :size                 ,presence: true
  validates :court_type           ,presence: true
  validates :business_status      ,inclusion: [true, false]
  validates :confirmation_status  ,inclusion: [true, false]

  enum court_type: {checking: 0, others: 1, gym: 2, asphalt: 3, sand: 4, rubber: 5}

  def fetch_pref_name
    return Prefecture.find(Area.find(area_id).prefecture_id).name
  end

  def self.convert_time_to_past_sec(hours, mins)
    hours_sec = hours.to_i * 60 * 60
    mins_sec = mins.to_i * 60
    return hours_sec + mins_sec
  end

  def return_business_hour
    if open_time && close_time
      return convert_open_time_to_hour_min + " ～ " + convert_close_time_to_hour_min
    else
      return '確認中'
    end
  end

  def fetch_tags
    tags = Tag.none
    CourtTagTagging.where(court_id: id).pluck(:tag_id).each do |tag_id|
      tags += Tag.where(id: tag_id)
    end
    return tags
  end

  def has_tag?(tag_name)
    Tag.where(id: court_tag_taggings.pluck(:tag_id)).each do |tag|
      return true if tag_name == tag.name
    end
    return false
  end

  def ave_total_points_reviews
    return court_reviews.pluck(:total_points).sum.fdiv(court_reviews.count)
  end

  def ave_accessibility_reviews
    return court_reviews.pluck(:accessibility).sum.fdiv(court_reviews.count)
  end

  def ave_security_reviews
    return court_reviews.pluck(:security).sum.fdiv(court_reviews.count)
  end

  def ave_quality_reviews
    return court_reviews.pluck(:quality).sum.fdiv(court_reviews.count)
  end

  def validate_about_name_address_area()
    # 可能ならエラーメッセジを引っ張ってきたい
    err_msg = ''
    if name.blank?
      err_msg += "コート名が入力されていません\n"
    end
    if address.blank?
      err_msg += "住所が入力されていません\n"
    end
    if area_id.blank?
      err_msg += "地域が入力されていません\n"
    end
    return err_msg
  end


  def set_default_values_to_court()
    if self.url.blank?
      puts 'うんｋ  '
      self.url = "確認中"
    end
    if self.supplement.blank?
      self.supplement = "確認中"
    end
    if self.size.blank?
      self.size = "確認中"
    end
    if self.price.blank?
      self.price = "確認中"
    end
    if self.court_type.blank?
      self.court_type = 0
    end
  end

  private
    def convert_open_time_to_hour_min
      return (Time.now.midnight + open_time).strftime("%H:%M")
    end

    def convert_close_time_to_hour_min
      return (Time.now.midnight + close_time).strftime("%H:%M")
    end

end
