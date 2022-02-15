class CourtReview < ApplicationRecord
  belongs_to :user
  belongs_to :court

  validates :court_id           ,presence: true, uniqueness: { scope: [:user_id], message: '既にレビューが投稿されています'}
  validates :user_id            ,presence: true
  validates :total_points       ,presence: true
  validates :accessibility      ,presence: true
  validates :security           ,presence: true
  validates :quality            ,presence: true

  def calc_total_points()
    scores = [accessibility, security, quality]
    unless scores.any? {|score| score.nil? }
      self.total_points = [accessibility, security, quality].sum.fdiv(3).round(1)
    else
      self.total_points = nil
    end
  end

end
