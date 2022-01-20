class CourtsController < ApplicationController
  def index
    if params[:keyword]
      @courts = Court.where('name LIKE ?', "%#{:keyword}%")
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
