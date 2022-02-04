class EventsController < ApplicationController
  def new; end

  def create; end

  def index
    @events = Event.all

    if params.dig(:court_id)
      @events = Event.where(court_id: params.dig(:court_id))
    end

    @courts = Court.where(confirmation_status: true).where(business_status: true)

    # リファクタリング、これ切り出せない？他のコントローラーに
    if params.dig(:prefecture, :id)
      @areas = Area.where(prefecture_id: params.dig(:prefecture, :id))
    end

    if params.dig(:Area, :area_ids)
      @area_search_res = Court.none
      params.dig(:Area, :area_ids).each do |area_id|
        @area_search_res = @area_search_res.or(@courts.where(area_id: area_id.to_i))
      end
      @courts = @area_search_res

    end

    @events = Event.where(court_id: @courts.pluck(:id))
    puts @events

    # リファクタリング予知あり
    # validationは後ほど

    if is_time_filled_in?('open') && is_time_filled_in?('close')
      open_time = extract_formatted_time_from_params('open')
      close_time = extract_formatted_time_from_params('close')
      @events = @events.where('open_time >= ?', open_time).where('close_time <= ?', close_time)
    elsif is_time_filled_in?('open')
      open_time = extract_formatted_time_from_params('open')
      @events = @events.where('open_time >= ?', open_time)
    elsif is_time_filled_in?('close')
      close_time = extract_formatted_time_from_params('close')
      @events = @events.where('close_time <= ?', close_time)
    end

    respond_to do |f|
      f.html
      f.js
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

  private
    def extract_formatted_time_from_params(str)
      datetime = Time.new(
        yaer = params.dig(:court, :"#{str}_time(1i)"),
        mon =  params.dig(:court, :"#{str}_time(2i)"),
        day =  params.dig(:court, :"#{str}_time(3i)"),
        hour = params.dig(:court, :"#{str}_time(4i)"),
        min =  params.dig(:court, :"#{str}_time(5i)"),
        )
      return datetime
    end

    def is_time_filled_in?(str)
      [*1..5].each do|n|
        if params.dig(:court, :"#{str}_time(#{n}i)").blank?
          return false
        end
      end
      return true
    end

end
