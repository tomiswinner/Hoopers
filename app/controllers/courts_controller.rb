class CourtsController < ApplicationController
  def index
    @courts = Court.where(confirmation_status: true).where(business_status: true)

    @courts += @courts.where('name LIKE ?', '%keyword%') if params[:keyword]

    @areas = Area.where(prefecture_id: params.dig(:prefecture, :id)) if params.dig(:prefecture, :id)

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
    # open, close 両方入力あれば=
    if params.dig(:court, :'ogipen_time(4i)').present? && params.dig(:court, :'close_time(4i)').present?
      open_time = Court.convert_time_to_past_sec(params.dig(:court, :'open_time(4i)'),
                                                 params.dig(:court, :'open_time(5i)'))
      close_time = Court.convert_time_to_past_sec(params.dig(:court, :'close_time(4i)'),
                                                  params.dig(:court, :'close_time(5i)'))
      @courts = @courts.where('open_time >= ?', open_time).where('close_time <= ?', close_time)
    end

    # close 空白 open 入力あれば
    if params.dig(:court, :'close_time(4i)').present? && params.dig(:court, :'open_time(4i)').blank?
      # リファクタリング余地あり
      close_time = Court.convert_time_to_past_sec(params.dig(:court, :'close_time(4i)'),
                                                  params.dig(:court, :'close_time(5i)'))
      @courts = @courts.where('close_time <= ?', close_time)
    end

    # opne 空白 close 入力あれば
    if params.dig(:court, :'open_time(4i)').present? && params.dig(:court, :'close_time(4i)').blank?
      # リファクタリング余地あり
      open_time = Court.convert_time_to_past_sec(params.dig(:court, :'open_time(4i)'),
                                                 params.dig(:court, :'open_time(5i)'))
      @courts = @courts.where('open_time >= ?', open_time)
    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  def address; end


  Lat_range = 0.02
  Lng_range = 0.05
  def map_check
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

  def new; end

  def confirm; end

  def create; end

  def thanks; end

  def map_search; end

  def detail
    @court = Court.find(params[:id])
  end

  private

  def courts_params
    params.require(:courts).permit(:name)
  end
end
