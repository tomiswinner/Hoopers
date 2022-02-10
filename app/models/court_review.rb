class CourtReview < ApplicationRecord
  belongs_to :user
  belongs_to :court

  def calc_total_points()
    self.total_points = [accessibility, security, quality].sum.fdiv(3).round(1)
  end

end
