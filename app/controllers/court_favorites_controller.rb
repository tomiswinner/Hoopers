class CourtFavoritesController < ApplicationController


  def create
    court_favorite = CourtFavorite.new(user_id: current_user.id, court_id: params[:id])
    if court_favorite.save
      respond_to do |format|
        format.js { render 'fav_destory.js', locals: {court_id: params[:id]} }
      end
    else
      flash[:alert] = '追加に失敗しました'
      redirect_back(fallback_location: root_path)
    end

  end

  def index
    @courts = Court.where(id: current_user.court_favorites.pluck(:court_id))
    @courts = Kaminari.paginate_array(@courts).page(params[:page]).per(10)
  end

  def destroy
    court_favorite = CourtFavorite.find_by(user_id: current_user.id, court_id: params[:id])
    if court_favorite.destroy
      respond_to do |format|
        format.js { render 'fav_create.js', locals: {court_id: params[:id]} }
      end
    else
      flash[:alert] = '削除に失敗しました'
      redirect_back(fallback_location: root_path)
    end
  end
end