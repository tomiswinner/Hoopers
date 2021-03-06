# rubocop:disable Metrics/ClassLength
class CourtsController < ApplicationController
  before_action -> { valid_time_field?('open') }, only: [:index, :confirm]
  before_action -> { valid_time_field?('close') }, only: [:index, :confirm]
  before_action -> { valid_keyword?(params[:keyword]) }, only: :index
  before_action -> { valid_pref_key?(params.dig(:prefecture, :id)) },\
                only: :index, if: proc { URI(request.referer.to_s).path == '/' }

  # rubocop:disable Metrics/AbcSize
  def index
    @courts = Court.where(confirmation_status: true)

    @prefecture_id = params.dig(:prefecture, :id)

    @areas = Area.where(prefecture_id: @prefecture_id) unless @prefecture_id.nil?

    # pref 検索
    @courts = @courts.where(area_id: @areas.pluck(:id)) unless @prefecture_id.nil?

    @courts = area_search(@courts, params.dig(:Area, :area_ids)) unless params.dig(:Area, :area_ids).nil?

    @courts = court_type_search(@courts, params.dig(:court, :court_types)) unless params.dig(:court, :court_types).nil?

    @courts = tag_search(@courts, params.dig(:Tag, :tag_ids)) unless params.dig(:Tag, :tag_ids).nil?

    # keyword 検索
    @courts = @courts.where('name LIKE ?', "%#{params[:keyword]}%") unless params[:keyword].nil?

    @courts = time_search(@courts)

    @courts = Kaminari.paginate_array(@courts).page(params[:page]).per(10)

    respond_to do |format|
      format.html
      format.js
    end
  end
  # rubocop:enable Metrics/AbcSize

  def address
    @address = params[:address]
  end

  def map_check
    res = fetch_geocoding_response(params.dig(:court, :address))
    if valid_request?(res) && !get_prefecture_id(res).nil?
      @prefecture_id = get_prefecture_id(res)
      geocoded_data = JSON.parse(res.body)
      @address = params.dig(:court, :address)
      @center_lat, @center_lng = return_latlng(geocoded_data)
      @courts = latlng_search(Court.all, @center_lat, @center_lng)
    else
      flash.now[:alert] = 'エラーが発生しました。住所が誤っている可能性があります。'
      render :address
    end
  end

  def new
    @court = Court.new(address: params[:address])
    @prefecture = Prefecture.find(params[:prefecture_id])
    @areas = Area.where(prefecture_id: params[:prefecture_id])
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def confirm
    @court = Court.new(courts_params)
    @tag_ids = params.dig(:Tag, :tag_ids)
    err_msg = @court.validate_about_name_address_area
    if err_msg.present?
      flash.now[:alert] = err_msg
      @prefecture = Prefecture.find(params[:prefecture_id])
      @areas = Area.where(prefecture_id: params[:prefecture_id])
      render :new
      return
    end
    @court.set_default_values_to_court
    res = fetch_geocoding_response(params.dig(:court, :address))
    if valid_request?(res)
      @court.latitude, @court.longitude = return_latlng(JSON.parse(res.body))
    else
      flash.now[:alert] = 'エラーが発生しました。住所が誤っている可能性があります。'
      render :new
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def create
    @court = Court.new(courts_params)
    @tag_ids = params[:tag_ids].split
    Court.transaction do
      @court = register_refile_from_confirmation(@court, params.dig(:court, :image))
      @court.save!
      @tag_ids.each do |id|
        CourtTagTagging.create!(court_id: @court.id, tag_id: id)
      end
    end
    flash[:notice] = 'コートが投稿されました'
    redirect_to(thanks_courts_path)
  rescue StandardError => e
    flash[:alert] = "予期せぬエラーが発生しました。\nお手数をおかけしますが、再度ご登録をお願いします。\n#{e}"
    redirect_to(address_courts_path)
  end

  def thanks; end

  def map_search
    latlng = JSON.parse(params[:latlng])
    @center_lat = latlng['latitude']
    @center_lng = latlng['longitude']
    @courts = Court.where(confirmation_status: true)
    @courts = latlng_search(@courts, @center_lat, @center_lng)
  end

  def show
    @court = Court.find(params[:id])
    @tags = Tag.where(id: @court.court_tag_taggings.pluck(:id))
    operate_court_history(@court, params[:id]) if user_signed_in?
  end

  private

  def courts_params
    return params.require(:court).permit(:user_id, :area_id, :name, :image, :open_time, :close_time, :supplement,
                                         :address, :url, :latitude, :longitude, :size, :price, :court_type,
                                         :business_status, :confirmation_status)
  end

  def valid_time_field?(str)
    # 全て空欄か埋まってればOK
    return if params.dig(:court, :"#{str}_time(4i)").blank? == params.dig(:court, :"#{str}_time(5i)").blank?

    flash[:alert] = '時間は時間と分、両方の入力が必要です。'
    redirect_back(fallback_location: root_path)
  end

  def valid_keyword?(keyword)
    return true if keyword.nil?

    if keyword.length.zero?
      flash[:alert] = 'キーワードが入力されていません'
      redirect_back(fallback_location: root_path)
    elsif keyword.length > 20
      flash[:alert] = 'キーワードは20文字までです'
      redirect_back(fallback_location: root_path)
    end
  end

  def court_type_search(courts, court_types)
    results = Court.none
    court_types.each do |court_type|
      results = results.or(courts.where(court_type: court_type))
    end
    return results
  end

  def tag_search(courts, tag_ids)
    tag_ids.each do |tag_id|
      court_ids = Tag.find(tag_id).court_tag_taggings.pluck(:court_id)
      courts = courts.where(id: court_ids)
    end
    return courts
  end

  def get_prefecture_id(res)
    geocoded_data = JSON.parse(res.body)
    components_length = geocoded_data['results'][0]['address_components'].length
    prefecture_name = geocoded_data['results'][0]['address_components'][components_length - 3]['long_name']
    pref = Prefecture.find_by(name: prefecture_name)
    return Prefecture.find_by(name: prefecture_name).id unless pref.nil?

    return nil
  end

  def time_filled_in?(str)
    ["#{str}_time(4i)", "#{str}_time(5i)"].each do |elem|
      return false if params.dig(:court, :"#{elem}").blank?
    end
    return true
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def time_search(courts)
    if time_filled_in?('open') && time_filled_in?('close')
      open_time = Court.convert_time_to_past_sec(params.dig(:court, :'open_time(4i)'),
                                                 params.dig(:court, :'open_time(5i)'))
      close_time = Court.convert_time_to_past_sec(params.dig(:court, :'close_time(4i)'),
                                                  params.dig(:court, :'close_time(5i)'))
      courts = courts.where('open_time >= ?', open_time).where('close_time <= ?', close_time)
    elsif time_filled_in?('close')
      close_time = Court.convert_time_to_past_sec(params.dig(:court, :'close_time(4i)'),
                                                  params.dig(:court, :'close_time(5i)'))
      courts = courts.where('close_time <= ?', close_time)
    elsif time_filled_in?('open')
      open_time = Court.convert_time_to_past_sec(params.dig(:court, :'open_time(4i)'),
                                                 params.dig(:court, :'open_time(5i)'))
      courts = courts.where('open_time >= ?', open_time)
    end
    return courts
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def operate_court_history(court, court_id)
    CourtHistory.find_by(user_id: current_user.id, court_id: court_id).destroy if current_user.history_exists?(court)
    CourtHistory.create(user_id: current_user.id, court_id: court_id)
    return unless current_user.histories_reached_to_limit?(court)

    CourtHistory.where(user_id: current_user.id).order(:created_at).first.destroy
  end
end
# rubocop:enable Metrics/ClassLength
