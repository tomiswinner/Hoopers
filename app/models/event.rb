class Event < ApplicationRecord
  attachment :image

  belongs_to :user
  belongs_to :court

  has_many :event_favorites, dependent: :destroy
  has_many :event_histories, dependent: :destroy

  validates :name           ,presence: true
  validates :court_id       ,presence: true
  validates :user_id        ,presence: true
  validates :description    ,presence: true
  validates :condition      ,presence: true
  validates :contact        ,presence: true
  validates :open_time      ,presence: true,  uniqueness: { scope: [:court_id, :user_id], message: '既に同じイベントを投稿しています。'}
  validates :close_time     ,presence: true
  validates :status         ,presence: true

  enum status: {closed: 0, wanted: 1}

  def is_event_in_favorite?
    # ログインしてない場合エラーあるな
    EventFavorite.where(event_id: id, user_id: current_user.id)
  end

  def return_event_time
    return "#{open_time.strftime('%Y/%m/%d %H:%M')} ～ #{close_time.strftime('%Y/%m/%d %H:%M')}"
  end

  def formatted_created_at
    return created_at.strftime('%Y/%m/%d')
  end
  def formatted_open_time
    return open_time.strftime('%Y/%m/%d %H:%M')
  end
  def formatted_close_time
    return close_time.strftime('%Y/%m/%d %H:%M')
  end
end
