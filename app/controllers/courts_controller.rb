class CourtsController < ApplicationController
  def index
    @courts = Court.where(confirmation_status: true).where(business_status: true)

    if params[:keyword]
      @courts += @courts.where('name LIKE ?', "%#{:keyword}%")
    end

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
    # コートタイプが一つ以上ついている場合（ついてない場合、[""]が入っている）
    if !(params.dig(:court, :court_types).blank?)
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

  def address; end

  def map_check; end

  def new; end

  def confirm; end

  def create; end

  def thanks; end

  def map_search; end

  def show
    @court = Court.find(params[:id])
  end

  private
    def courts_params
      params.require(:courts).permit(:name)
    end
end
