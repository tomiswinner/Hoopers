class EventFavorite < ApplicationRecord
  belongs_to :event
  belongs_to :user

  validates :event_id       ,presence: true,  uniqueness: { scope: :user_id, message: '既にリストに追加されています。'}
  validates :user_id        ,presence: true
end
