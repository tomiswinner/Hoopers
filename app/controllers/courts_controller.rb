class CourtsController < ApplicationController
  before_action -> { is_valid_time_field?("open")}, only: :index
  before_action -> { is_valid_time_field?("close")}, only: :index


  def index
    @courts = Court.where(confirmation_status: true).where(business_status: true)

    @courts += @courts.where('name LIKE ?', '%keyword%') if params[:keyword]

    @areas = Area.where(prefecture_id: params.dig(:prefecture, :id)) if params.dig(:prefecture, :id)

    if params.dig(:prefecture, :id)
      @courts = @courts.where(area_id: Area.where(prefecture_id: params.dig(:prefecture, :id)).ids)
    end
    if params.dig(:Area, :area_ids)
      @area_search_res = Court.none
      params.dig(:Area, :area_ids).each do |area_id|
        @area_search_res = @area_search_res.or(@courts.where(area_id: area_id.to_i))
      end
      @courts = @area_search_res

    end
    # コートタイプが一つ以上ついている場合（ついてない場合、[""]が入っている）
    if params.dig(:court, :court_types).present?
      # リファクタリング余地あり
      @court_type_search_res = Court.none
      params.dig(:court, :court_types).each do |court_type|
        @court_type_search_res = @court_type_search_res.or(@courts.where(court_type: court_type))
      end
      @courts = @court_type_search_res
    end

    if params.dig(:Tag, :tag_ids)
      @tag_search_res = Court.none
      params.dig(:Tag, :tag_ids).each do |tag_id|
        Tag.find(tag_id).court_tag_taggings.each do |tagging|
          @tag_search_res = @tag_search_res.or(@courts.where(id: tagging.court_id))
        end
      end
      @courts = @tag_search_res
    end

    # open_time,close time はそれぞれ 分まで一緒に入れるようvalidation 入れる
    if time_filled_in?('open') && time_filled_in?('close')
      open_time = Court.convert_time_to_past_sec(params.dig(:court, :'open_time(4i)'),
                                                 params.dig(:court, :'open_time(5i)'))
      close_time = Court.convert_time_to_past_sec(params.dig(:court, :'close_time(4i)'),
                                                  params.dig(:court, :'close_time(5i)'))
      @courts = @courts.where('open_time >= ?', open_time).where('close_time <= ?', close_time)
    elsif time_filled_in?('close')
      close_time = Court.convert_time_to_past_sec(params.dig(:court, :'close_time(4i)'),
                                                  params.dig(:court, :'close_time(5i)'))
      @courts = @courts.where('close_time <= ?', close_time)
    elsif time_filled_in?('open')
      open_time = Court.convert_time_to_past_sec(params.dig(:court, :'open_time(4i)'),
                                                 params.dig(:court, :'open_time(5i)'))
      @courts = @courts.where('open_time >= ?', open_time)
    end

    @courts =   Kaminari.paginate_array(@courts).page(params[:page]).per(10)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def address
    @address = params[:address]
  end

  def map_check
    res = fetch_geocoding_response(params.dig(:court, :address))
    if !res.nil? && res.message == 'OK'
      # リファクタリング
      geocoded_data = JSON.parse(res.body)
      components_length = geocoded_data['results'][0]['address_components'].length
      prefecture_name = geocoded_data['results'][0]['address_components'][components_length - 3]['long_name']
      @prefecture_id = Prefecture.find_by(name: prefecture_name).id
      @address = params.dig(:court, :address)
      @center_lat = geocoded_data['results'][0]['geometry']['location']['lat']
      @center_lng = geocoded_data['results'][0]['geometry']['location']['lng']
      @courts = Court.where('? <= latitude', @center_lat - Lat_range).where('? >= latitude', @center_lat + Lat_range)
      @courts = @courts.where('? <= longitude', @center_lng - Lng_range).where('? >= longitude',
                                                                               @center_lng + Lng_range)
    else
      # リファクタリング
      flash.now[:alert] = 'エラーが発生しました。住所が誤っている可能性があります。'
      render :address
    end
  end

  def new
    @court = Court.new(address: params[:address])
    @prefecture = Prefecture.find(params[:prefecture_id])
    @areas = Area.where(prefecture_id: params[:prefecture_id])
  end

  def confirm
    @court = Court.new(courts_params)
    # name,addres,area の validation
    err_msg = @court.validate_about_name_address_area()
    unless err_msg.blank?
      flash.now[:alert] = err_msg
      @prefecture = Prefecture.find(params[:prefecture_id])
      @areas = Area.where(prefecture_id: params[:prefecture_id])
      render :new
      return
    end
    @court.set_default_values_to_court()
    # リファクタリング
    res = fetch_geocoding_response(params.dig(:court, :address))
    if !res.nil? && res.message == 'OK'
      geocoded_data = JSON.parse(res.body)
      @court.latitude = geocoded_data['results'][0]['geometry']['location']['lat']
      @court.longitude = geocoded_data['results'][0]['geometry']['location']['lng']
    else
      flash.now[:alert] = 'エラーが発生しました。住所が誤っている可能性があります。'
      render :new
    end
  end

  def create
    @court = Court.new(courts_params)
    if @court.save
      flash[:notice] = 'コートが投稿されました'
      redirect_to(thanks_courts_path)
    else
      err_msg = "コートの投稿に失敗しました。\n"
      @court.errors.full_messages.each do |msg|
        err_msg += "#{msg}\n"
      end
      flash.now[:alert] = err_msg
      render :confirm
    end
  end

  def thanks; end

  def map_search
    latlng = JSON.parse(params[:latlng])
    @center_lat = latlng["latitude"]
    @center_lng = latlng["longitude"]
    @courts = Court.where('? <= latitude', @center_lat - Lat_range).where('? >= latitude', @center_lat + Lat_range)
    @courts = @courts.where('? <= longitude', @center_lng - Lng_range).where('? >= longitude',
                                                                             @center_lng + Lng_range)
  end

  def show
    @court = Court.find(params[:id])
    @tags = Tag.where(id: @court.court_tag_taggings.pluck(:id))
    return unless user_signed_in?
      if current_user.history_exists?(@court)
        CourtHistory.find_by(user_id: current_user.id, court_id: params[:id]).destroy
      end
      CourtHistory.create(user_id: current_user.id, court_id: params[:id])
      return unless current_user.histories_reached_to_limit?(@court)
        CourtHistory.where(user_id: current_user.id).order(:created_at).first.destroy
  end

  private

  def courts_params
    return params.require(:court).permit(:user_id, :area_id, :name, :image, :open_time, :close_time, :supplement,
                                         :address, :url, :latitude, :longitude, :size, :price, :court_type, :business_status, :confirmation_status)
  end

  def time_filled_in?(str)
    ["#{str}_time(4i)","#{str}_time(5i)"].each do |elem|
      return false if params.dig(:court, :"#{elem}").blank?
    end
    return true
  end

  def is_valid_time_field?(str)
    # 全て空欄か埋まってればOK
    unless params.dig(:court, :"#{str}_time(4i)").blank? == params.dig(:court, :"#{str}_time(5i)").blank?
      flash[:alert] = "時間検索では時間と分、両方の入力が必要です。"
      redirect_back(fallback_location: root_path)
    end
  end

end
