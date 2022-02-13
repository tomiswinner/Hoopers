class CourtHistoriesController < ApplicationController
  def index
    @courts = Court.none
    CourtHistory.where(user_id: current_user).order(created_at: :desc).each do |hisotory|
      @courts += Court.where(id: hisotory.court_id)
    end

    @courts =   Kaminari.paginate_array(@courts).page(params[:page]).per(10)
  end
end
