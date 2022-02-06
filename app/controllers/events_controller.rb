class EventsController < ApplicationController
  def new
    @court_id = params[:court_id]
    @event = Event.new()
  end

  def create
    @event = Event.new(events_params)
    puts @event
    puts events_params
    puts 'うんｋ'
    if @event.save
      flash.now[:notice] = 'イベントが投稿されました'
      redirect_to(event_path(@event.id))
    else
      err_msg = "イベント投稿に失敗しました。\n"
      @event.errors.full_messages.each do |msg|
        err_msg += msg + "\n"
      end
      flash[:alert] = err_msg
      render :confirm
    end

  end

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

  def confirm
    @event = Event.new(events_params)
  end

  def address; end

  def court_select
    res = fetch_geocoding_response(params.dig(:court, :address))
    if !(res.nil?) && res.message == 'OK'
      geocoded_data = JSON.parse(res.body)
      @center_lat = geocoded_data["results"][0]['geometry']['location']['lat']
      @center_lng = geocoded_data["results"][0]['geometry']['location']['lng']
      @courts = Court.where('? <= latitude', @center_lat - Lat_range).where('? >= latitude', @center_lat + Lat_range)
      @courts = @courts.where('? <= longitude', @center_lng - Lng_range).where('? >= longitude', @center_lng + Lng_range)

    else
      # リファクタリング
      flash.now[:alert] = "エラーが発生しました。"
    end
  end

  private
    def events_params
      return params.require(:event).permit(:user_id, :court_id, :name, :image, :description, :condition, :contact, :open_time, :close_time, :status)
    end

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
