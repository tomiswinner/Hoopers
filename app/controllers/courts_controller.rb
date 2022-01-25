class CourtsController < ApplicationController
  def index
    @prefectures = Prefecture.all
    @courts = Court.all
    if params[:keyword]
      @courts = Court.where('name LIKE ?', "%#{:keyword}%")
    end

    if params[:prefecture_id]
      @areas = Area.where(prefecture_id: params[:prefecture_id])
    end

    if params.dig(:Area, :area_ids)
      params.dig(:Area, :area_ids).each do |area_id|
        puts area_id
        puts 'うんｋ'
        @courts = @courts.or(Court.where(area_id: area_id.to_i))
        puts @courts
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
