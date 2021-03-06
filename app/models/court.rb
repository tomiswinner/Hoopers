class Court < ApplicationRecord
  attachment :image

  belongs_to :user
  belongs_to :area

  has_many :events,             dependent: :destroy
  has_many :court_reviews,      dependent: :destroy
  has_many :court_favorites,    dependent: :destroy
  has_many :court_histories,    dependent: :destroy
  has_many :court_tag_taggings, dependent: :destroy
  has_many :court_infos,        dependent: :destroy

  validates :name, presence: true, length: { maximum: 20 }
  validates :user_id, presence: true
  validates :area_id, presence: true
  validates :latitude, presence: true
  validates :longitude, presence: true
  validates :url, presence: true
  validates :address, presence: true, uniqueness: true
  validates :supplement, presence: true
  validates :size, presence: true
  validates :court_type, presence: true
  validates :business_status, inclusion: [true, false]
  validates :confirmation_status, inclusion: [true, false]

  enum court_type: { checking: 0, others: 1, gym: 2, asphalt: 3, sand: 4, rubber: 5 }

  def fetch_pref_name
    return Prefecture.find(Area.find(area_id).prefecture_id).name
  end

  def self.convert_time_to_past_sec(hours, mins)
    hours_sec = hours.to_i * 60 * 60
    mins_sec = mins.to_i * 60
    return hours_sec + mins_sec
  end

  def return_business_hour
    return "#{convert_open_time_to_hour_min} ～ #{convert_close_time_to_hour_min}" if open_time && close_time

    return '確認中'
  end

  def select_tags
    tagging_ids = court_tag_taggings.pluck(:id)
    return Tag.where(id: tagging_ids)
  end

  def exists_tag?(tag_id)
    return court_tag_taggings.pluck(:tag_id).any? { |court_tag_id| court_tag_id == tag_id }
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

  def validate_about_name_address_area
    err_msg = ''
    err_msg += "コート名が入力されていません\n" if name.blank?
    err_msg += "コート名は20文字までです\n" if name.length > 20
    err_msg += "住所が入力されていません\n" if address.blank?
    err_msg += "既に現在の住所のコートは登録されています。情報反映までお待ちください。\n" if Court.where(address: address).count.positive?
    err_msg += "地域が入力されていません\n" if area_id.blank?
    return err_msg
  end

  def set_default_values_to_court
    self.url = '確認中' if url.blank?
    self.supplement = '確認中' if supplement.blank?
    self.size = '確認中' if size.blank?
    self.price = '確認中' if price.blank?
    self.court_type = 0 if court_type.blank?
  end

  def return_image_id
    return image.id unless image.nil?

    return nil
  end

  private

  def convert_open_time_to_hour_min
    return (Time.zone.now.midnight + open_time).strftime('%H:%M')
  end

  def convert_close_time_to_hour_min
    return (Time.zone.now.midnight + close_time).strftime('%H:%M')
  end
end
