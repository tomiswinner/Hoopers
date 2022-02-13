class EventsController < ApplicationController
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

    # リファクタリング、これ切り出せない？他のコントローラーに
    @areas = Area.where(prefecture_id: params.dig(:prefecture, :id)) if params.dig(:prefecture, :id)

    if params.dig(:Area, :area_ids)
      @area_search_res = Court.none
      params.dig(:Area, :area_ids).each do |area_id|
        @area_search_res = @area_search_res.or(@courts.where(area_id: area_id.to_i))
      end
      @courts = @area_search_res

    end

    if params.dig(:fav_court_id)
      @courts = Court.where(id: params.dig(:fav_court_id))
      puts 'こうげ'
      puts @courts
    end

    @events = Event.where(court_id: @courts.pluck(:id))

    # リファクタリング予知あり
    # validationは後ほど

    if time_filled_in?('open') && time_filled_in?('close')
      open_time = extract_formatted_time_from_params('open')
      close_time = extract_formatted_time_from_params('close')
      @events = @events.where('open_time >= ?', open_time).where('close_time <= ?', close_time)
    elsif time_filled_in?('open')
      open_time = extract_formatted_time_from_params('open')
      @events = @events.where('open_time >= ?', open_time)
    elsif time_filled_in?('close')
      close_time = extract_formatted_time_from_params('close')
      @events = @events.where('close_time <= ?', close_time)
    end


    @events =   Kaminari.paginate_array(@events).page(params[:page]).per(10)

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
    if @event.update(events_params_for_datetime)
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
    @event = Event.new(events_params_for_datetime)
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
      @courts = Court.where('? <= latitude', @center_lat - Lat_range).where('? >= latitude', @center_lat + Lat_range)
      @courts = @courts.where('? <= longitude', @center_lng - Lng_range).where('? >= longitude',
                                                                               @center_lng + Lng_range)
    else
      # リファクタリング
      flash.now[:alert] = 'エラーが発生しました。'
      render :address
    end
  end

  private

  def events_params_for_datetime
    params[:event][:open_time] = extract_formatted_time_from_params('open')
    params[:event][:close_time] = extract_formatted_time_from_params('close')
    delete_unnecessary_time_params('open')
    delete_unnecessary_time_params('close')
    return params.require(:event).permit(:user_id, :court_id, :name, :image, :description, :condition, :contact,
                                         :open_time, :close_time, :status)
  end

  def events_params
    return params.require(:event).permit(:user_id, :court_id, :name, :image, :description, :condition, :contact,
                                         :open_time, :close_time, :status)
  end

  def delete_unnecessary_time_params(str)
    params[:event].delete(:"#{str}_time(4i)")
    params[:event].delete(:"#{str}_time(5i)")
  end

  def extract_formatted_time_from_params(str)
    date = params.dig(:event, :"date")
    hour = params.dig(:event, :"#{str}_time(4i)")
    min = params.dig(:event, :"#{str}_time(5i)")

    datetime = Time.parse("#{date} #{hour}:#{min}")
    return datetime
  end

  
  
end
