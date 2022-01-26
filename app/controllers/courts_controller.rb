class CourtsController < ApplicationController
  def index
    @prefectures = Prefecture.all
    @courts = Court.none
    if params[:keyword]
      @courts = @courts.or(Court.where('name LIKE ?', "%#{:keyword}%"))
    end

    if params.dig(:prefecture, :id)
      @areas = Area.where(prefecture_id: params.dig(:prefecture, :id))
    end

    if params.dig(:Area, :area_ids)
      params.dig(:Area, :area_ids).each do |area_id|
        @courts = @courts.or(Court.where(area_id: area_id.to_i))
      end
    end
    
    # 時間が一つでも入力されていれば
    if params[:Court].values.any? {|elem| !( elem.empty?)}
      # open_time,close time はそれぞれ 分まで一緒に入れるようvalidation 入れる
      @courts = @courts.or(Court.where())
      
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
