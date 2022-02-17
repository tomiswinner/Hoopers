class EventsController < ApplicationController
  before_action -> { valid_time_field?('open') }, only: :index
  before_action -> { valid_time_field?('close') }, only: :index

  def new
    @event = Event.new(court_id: params[:court_id])
  end

  def create
    @event = Event.new(events_params)
    if @event.save
      flash[:notice] = 'イベントが投稿されました'
      redirect_to(event_path(@event.id))
    else
      err_msg = "イベント投稿に失敗しました。\n"
      @event.errors.full_messages.each do |msg|
        err_msg += "#{msg}\n"
      end
      flash.now[:alert] = err_msg
      render :confirm
    end
  end

  def index
    @events = Event.all

    @events = Event.where(court_id: params[:court_id]) if params[:court_id]

    @courts = Court.where(confirmation_status: true).where(business_status: true)

    @prefecture_id = params.dig(:prefecture, :id)

    @areas = Area.where(prefecture_id: @prefecture_id) unless @prefecture_id.nil?

    @courts = @courts.where(area_id: @areas.pluck(:id)) unless @prefecture_id.nil?

    @courts = area_search(@courts, params.dig(:Area, :area_ids)) unless params.dig(:Area, :area_ids).nil?

    if params.dig(:fav_court_id)
      @courts = Court.where(id: params.dig(:fav_court_id))
    end

    @events = Event.where(court_id: @courts.pluck(:id))

    @events = time_search(@events)

    @events =   Kaminari.paginate_array(@events.order(created_at: 'DESC')).page(params[:page]).per(10)

    respond_to do |f|
      f.html
      f.js
    end
  end

  def show
    @event = Event.find(params[:id])
    return unless user_signed_in?
      if current_user.history_exists?(@event)
        EventHistory.find_by(user_id: current_user.id, event_id: params[:id]).destroy
      end
      EventHistory.create(user_id: current_user.id, event_id: params[:id])
      return unless current_user.histories_reached_to_limit?(@event)
        EventHistory.where(user_id: current_user.id).order(:created_at).first.destroy

  end

  def edit
    @event = Event.find(params[:id])
  end

  def update
    @event = Event.find(params[:id])
    if @event.update(events_params)
      flash[:notice] = 'イベントが修正されました'
      redirect_to(event_path(@event.id))
    else
      err_msg = "イベントの修正に失敗しました。\n"
      @event.errors.full_messages.each do |msg|
        err_msg += "#{msg}\n"
      end
      flash.now[:alert] = err_msg
      render :edit
    end
  end

  def destroy
    @event = Event.find(params[:id])
    if @event.destroy
      flash[:notice] = 'イベントを削除しました'
      redirect_to(root_path)
    else
      flash.now[:alert] = 'イベントの削除に失敗しました'
      render :edit
    end
  end

  def confirm
    @event = Event.new(events_params)
    return unless @event.invalid?

    err_msg = "イベント投稿に必要な内容が不足しています。\n"
    @event.errors.full_messages.each do |msg|
      err_msg += "#{msg}\n"
    end
    flash.now[:alert] = err_msg
    render :new
  end

  def address; end

  def court_select
    res = fetch_geocoding_response(params.dig(:court, :address))
    if !res.nil? && res.message == 'OK'
      geocoded_data = JSON.parse(res.body)
      @entered_address = params.dig(:court, :address)
      @center_lat = geocoded_data['results'][0]['geometry']['location']['lat']
      @center_lng = geocoded_data['results'][0]['geometry']['location']['lng']
      @courts = Court.where(confirmation_status: true)
      @courts = @courts.where('? <= latitude', @center_lat - Lat_range).where('? >= latitude', @center_lat + Lat_range)
      @courts = @courts.where('? <= longitude', @center_lng - Lng_range).where('? >= longitude',
                                                                               @center_lng + Lng_range)
    else
      # リファクタリング
      flash.now[:alert] = 'エラーが発生しました。'
      render :address
    end
  end

  private

  def extract_formatted_time_from_params(str)
    datetime = Time.new(
      yaer = params.dig(:event, :"#{str}_time(1i)"),
      mon =  params.dig(:event, :"#{str}_time(2i)"),
      day =  params.dig(:event, :"#{str}_time(3i)"),
      hour = params.dig(:event, :"#{str}_time(4i)"),
      min =  params.dig(:event, :"#{str}_time(5i)"),
      )
    return datetime
  end

  def time_filled_in?(str)

    [*1..5].each do|n|
      if params.dig(:event, :"#{str}_time(#{n}i)").blank?
        return false
      end
    end
    return true
  end

  def time_search(events)
    if time_filled_in?('open') && time_filled_in?('close')
      open_time = extract_formatted_time_from_params('open')
      close_time = extract_formatted_time_from_params('close')
      events = events.where('open_time >= ?', open_time).where('close_time <= ?', close_time)
    elsif time_filled_in?('open')
      open_time = extract_formatted_time_from_params('open')
      events = events.where('open_time >= ?', open_time)
    elsif time_filled_in?('close')
      close_time = extract_formatted_time_from_params('close')
      events = events.where('close_time <= ?', close_time)
    end
    return events
  end

  def events_params
    return params.require(:event).permit(:user_id, :court_id, :name, :image, :description, :condition, :contact,
                                         :open_time, :close_time, :status)
  end


  def valid_time_field?(str)
    # 全て空欄か埋まってればOK
    bool = params.dig(:event, :"#{str}_time(1i)").blank?
    [*2..5].each do |n|
      if bool != params.dig(:event, :"#{str}_time(#{n}i)").blank?
        flash[:alert] = '時間検索には開始時刻・終了時刻どちらかはすべての入力が必要です。'
        redirect_back(fallback_location: root_path)
        return
      end
    end
  end

end
