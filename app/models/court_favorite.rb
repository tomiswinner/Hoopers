class CourtFavorite < ApplicationRecord
  belongs_to :court
  belongs_to :user

  validates :court_id       ,presence: true,  uniqueness: { scope: :user_id, message: '既にお気に入りに追加されています。'}
  validates :user_id        ,presence: true
end
