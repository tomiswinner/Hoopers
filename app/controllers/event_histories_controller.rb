class EventHistoriesController < ApplicationController
  def index
    @events = Event.none
    EventHistory.where(user_id: current_user).order(created_at: :desc).each do |hisotory|
      @events += Event.where(id: hisotory.event_id)
    end
    @events =   Kaminari.paginate_array(@events).page(params[:page]).per(10)
  end
end
