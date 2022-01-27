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
        @courts = Court.where(area_id: area_id.to_i)
      end
    end

    # 時間が一つでも入力されていれば
    if params[:Court].values.any? {|elem| !( elem.empty?)}
      # open_time,close time はそれぞれ 分まで一緒に入れるようvalidation 入れる

      # open, close 両方入力あれば
      if params.dig(:Court, :'open_time(4i)')&& params.dig(:Court, :'close_time(4i)')
        open_time = Court.convert_time_to_past_sec(params.dig(:Court, :'open_time(4i)'), params.dig(:Court, :'open_time(5i)'))
        close_time = Court.convert_time_to_past_sec(params.dig(:Court, :'close_time(4i)'), params.dig(:Court, :'close_time(5i)'))
        @courts = Court.where('open_time >= ?', open_time).where('close_time <= ?', close_time)
      end

    #   if params.dig(:Court, :'open_time(4i)').blank?
    #     # リファクタリング余地あり
    #     close_time = params.dig(:Court, :'close_time(4i)') + ':' + params.dig(:Court, :'close_time(5i)')
    #     @courts = Court.where('close_time <= ?', close_time)
    #   end

    #   if params.dig(:Court, :'close_time(4i)').blank?
    #     # リファクタリング余地あり
    #     open_time = params.dig(:Court, :'open_time(4i)') +':'+ params.dig(:Court, :'open_time(5i)')
    #     @courts = Court.where('open_time >= ?', open_time)
      # end
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
