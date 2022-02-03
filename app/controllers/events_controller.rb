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
    
    
    
    
    if !(params.dig(:court, :court_types).blank?)
      # リファクタリング余地あり
      @court_type_search_res = Court.none
      params.dig(:court, :court_types).each do |court_type|
        @court_type_search_res = @court_type_search_res.or(@courts.where(court_type: court_type))
      end
      @courts = @court_type_search_res
    end

    # open_time,close time はそれぞれ 分まで一緒に入れるようvalidation 入れる
    # open, close 両方入力あれば=
    if !(params.dig(:court, :'ogipen_time(4i)').blank?)&& !(params.dig(:court, :'close_time(4i)').blank?)
      open_time = Court.convert_time_to_past_sec(params.dig(:court, :'open_time(4i)'), params.dig(:court, :'open_time(5i)'))
      close_time = Court.convert_time_to_past_sec(params.dig(:court, :'close_time(4i)'), params.dig(:court, :'close_time(5i)'))
      @courts = @courts.where('open_time >= ?', open_time).where('close_time <= ?', close_time)
    end

    # close 空白 open 入力あれば
    if !(params.dig(:court, :'close_time(4i)').blank?)&& params.dig(:court, :'open_time(4i)').blank?
      # リファクタリング余地あり
      close_time = Court.convert_time_to_past_sec(params.dig(:court, :'close_time(4i)'), params.dig(:court, :'close_time(5i)'))
      @courts = @courts.where('close_time <= ?', close_time)
    end

    # opne 空白 close 入力あれば
    if !(params.dig(:court, :'open_time(4i)').blank?)&& params.dig(:court, :'close_time(4i)').blank?
      # リファクタリング余地あり
      open_time = Court.convert_time_to_past_sec(params.dig(:court, :'open_time(4i)'), params.dig(:court, :'open_time(5i)'))
      @courts = @courts.where('open_time >= ?', open_time)
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
end
