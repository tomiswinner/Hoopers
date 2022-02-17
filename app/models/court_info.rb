class CourtInfo < ApplicationRecord
  belongs_to :court
  belongs_to :user

  validates :court_id, presence: true,
                       uniqueness: { scope: :user_id, message: '既にこちらのコートの情報を提供済みです。新たな投稿はしばらくお待ちください' }
  validates :user_id, presence: true
  validates :information, presence: true
  validates :status, inclusion: [true, false]

  def court_name
    return Court.find(court_id).name
  end
end
