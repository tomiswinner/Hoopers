class CourtHistoriesController < ApplicationController
  def index
    @courts = Court.where(id: CourtHistory.where(user_id: current_user).pluck(:court_id)).order(created_at: :desc)
  end
end
