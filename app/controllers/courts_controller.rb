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

    if params.dig(:Court, :court_types)
      # リファクタリング余地あり
      # 検索をかけていった段階で、検索結果が0となった時、これだとエラーが起きるわ、、、
      # 足し算できるのはokだが、whereがこれだと被らない、、、
      # areasearch では、初めて where 条件が被るから大丈夫だけど、
      @court_type_search_res = Court.none
      params.dig(:Court, :court_types).each do |court_type|
        # ここで、court_type_seach_res には@courts を絞った内容が入ってる。。あれだから、@court_type_search_res を @courts に代入最後にしちゃえばいいのかな
        # いや、これは Court が all じゃないと成り立たな、、、そんなことないか？いや、ある、court.allじゃないと成り立たない。
        # court.none の場合、@courts じゃなくて、Court で where検索が必要になる。
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
    # open, close 両方入力あれば
    if params.dig(:Court, :'ogipen_time(4i)')&& params.dig(:Court, :'close_time(4i)')
      open_time = Court.convert_time_to_past_sec(params.dig(:Court, :'open_time(4i)'), params.dig(:Court, :'open_time(5i)'))
      close_time = Court.convert_time_to_past_sec(params.dig(:Court, :'close_time(4i)'), params.dig(:Court, :'close_time(5i)'))
      @courts = @courts.where('open_time >= ?', open_time).where('close_time <= ?', close_time)
    end

    if params.dig(:Court, :'close_time(4i)')&&params.dig(:Court, :'open_time(4i)').blank?
      # リファクタリング余地あり
      close_time = Court.convert_time_to_past_sec(params.dig(:Court, :'close_time(4i)'), params.dig(:Court, :'close_time(5i)'))
      @courts = @courts.where('close_time <= ?', close_time)
    end

    if params.dig(:Court, :'open_time(4i)')&&params.dig(:Court, :'close_time(4i)').blank?
      # リファクタリング余地あり
      open_time = Court.convert_time_to_past_sec(params.dig(:Court, :'open_time(4i)'), params.dig(:Court, :'open_time(5i)'))
      @courts = Court.where('open_time >= ?', open_time)
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

  def show; end

  private
    def courts_params
      params.require(:courts).permit(:name)
    end
end
