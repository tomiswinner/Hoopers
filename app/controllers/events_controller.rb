class EventsController < ApplicationController
  def new; end

  def create; end

  def index
    @events = Event.all
    if params.dig(:court_id)
      @events = Event.where(court_id: params.dig(:court_id))
    end
  end

  def show
    @event = Event.find(params[:id])
  end

  def edit; end

  def update; end

  def destroy; end

  def confirm; end

  def address; end

  def court_select; end
end
