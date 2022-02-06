class Event < ApplicationRecord
  attachment :image
  
  belongs_to :user
  belongs_to :court

  has_many :event_favorites, dependent: :destroy
  has_many :event_histories, dependent: :destroy

  def is_event_in_favorite?
    # ログインしてない場合エラーあるな
    EventFavorite.where(event_id: id, user_id: current_user.id)
  end

  def return_event_time
    return "#{open_time.strftime('%Y年%m月%d日 %H:%M')} ～ #{close_time.strftime('%Y年%m月%d日 %H:%M')}"
  end
end
