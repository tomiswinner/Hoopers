class CourtInfosController < ApplicationController
  def new
    @court = Court.find(params[:court_id])
    @court_info = CourtInfo.new
  end

  def create
    @court_info = CourtInfo.new(court_info_params)

    if @court_info.save
      flash[:notice] = 'コート情報の共有がされました！'
      redirect_to court_info_path(@court_info.id)
    else
      flash.now[:alert] = "情報投稿に失敗しました\n既にコートの情報を共有されています。"
      render :new
    end
  end

  def show
    @court_info = CourtInfo.find(params[:id])
    @court = Court.find(@court_info.court_id)
  end

  def index
    @court_infos = CourtInfo.where(user_id: current_user.id)
  end

  def edit
    @court_info = CourtInfo.find(params[:id])
    @court = Court.find(@court_info.court_id)
  end

  def update
    @court_info = CourtInfo.find(params[:id])

    if @court_info.update(court_info_params)
      flash[:notice] = '投稿が修正されました！'
      redirect_to court_info_path(@court_info.id)
    else
      flash.now[:alert] = '投稿修正に失敗しました'
      render :edit
    end
  end

  def destroy
    @court_info = CourtInfo.find(params[:id])
    if @court_info.destroy
      flash[:notice] = '投稿を削除しました'
      redirect_to(court_infos_path)
    else
      flash.now[:alert] = '投稿の削除に失敗しました'
      render :edit
    end
  end

  private

  def court_info_params
    params.require(:court_info).permit(:information, :user_id, :court_id, :status)
  end
end
