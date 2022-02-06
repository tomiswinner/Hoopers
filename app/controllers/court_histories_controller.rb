class CourtHistoriesController < ApplicationController
  def index
    @courts = Court.none
    CourtHistory.where(user_id: current_user).order(created_at: :desc).each do |hisotory|
      @courts += Court.where(id: hisotory.court_id)
    end
  end
end
