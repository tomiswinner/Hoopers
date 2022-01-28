class CourtsController < ApplicationController
  def index
    @prefectures = Prefecture.all
    @courts = Court.none
    if params[:keyword]
      @courts = Court.where('name LIKE ?', "%#{:keyword}%")
    end

    if params.dig(:prefecture, :id)
      @areas = Area.where(prefecture_id: params.dig(:prefecture, :id))
    end

    if params.dig(:Area, :area_ids)
      params.dig(:Area, :area_ids).each do |area_id|
        @courts = @courts.or(Court.where(area_id: area_id.to_i))
      end
    end
    # open_time,close time はそれぞれ 分まで一緒に入れるようvalidation 入れる
    # open, close 両方入力あれば
    if params.dig(:Court, :'open_time(4i)')&& params.dig(:Court, :'close_time(4i)')
      open_time = Court.convert_time_to_past_sec(params.dig(:Court, :'open_time(4i)'), params.dig(:Court, :'open_time(5i)'))
      close_time = Court.convert_time_to_past_sec(params.dig(:Court, :'close_time(4i)'), params.dig(:Court, :'close_time(5i)'))
      if @courts.count == 0
        @courts = @courts.or(Court.where('open_time >= ?', open_time).where('close_time <= ?', close_time))
      else
        @courts = @courts.where('open_time >= ?', open_time).where('close_time <= ?', close_time)
      end
    end

    if params.dig(:Court, :'close_time(4i)')&&params.dig(:Court, :'open_time(4i)').blank?
      # リファクタリング余地あり
      close_time = Court.convert_time_to_past_sec(params.dig(:Court, :'close_time(4i)'), params.dig(:Court, :'close_time(5i)'))
      if @courts.count == 0
        @courts = @courts.or(Court.where('close_time <= ?', close_time))
      else
        @courts = @courts.where('close_time <= ?', close_time)
      end
    end

    if params.dig(:Court, :'open_time(4i)')&&params.dig(:Court, :'close_time(4i)').blank?
      # リファクタリング余地あり
      open_time = Court.convert_time_to_past_sec(params.dig(:Court, :'open_time(4i)'), params.dig(:Court, :'open_time(5i)'))
      if @courts.count == 0
        @courts = Court.where('open_time >= ?', open_time)
      else
        @courts = Court.where('open_time >= ?', open_time)
      end
    end


    if params.dig(:Court, :court_types)
      # リファクタリング余地あり
      # 検索をかけていった段階で、検索結果が0となった時、これだとエラーが起きるわ、、、
      params.dig(:Court, :court_types).each do |court_type|
        if @courts.count
          @courts = Court.where(court_type: court_type)
        else
          @courts = @courts.or(Court.where(court_type: court_type))
        end
      end
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
