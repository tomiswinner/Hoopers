class EventHistory < ApplicationRecord
  belongs_to :event
  belongs_to :user

  validates :event_id      ,presence: true,  uniqueness: { scope: :user_id, message: 'イベント履歴にエラーが発生しました'}
  validates :user_id       ,presence: true
end
