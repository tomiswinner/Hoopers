class CourtHistory < ApplicationRecord
  belongs_to :court
  belongs_to :user

  validates :court_id      ,presence: true,  uniqueness: { scope: :user_id, message: 'コート履歴にエラーが発生しました'}
  validates :user_id       ,presence: true
end
