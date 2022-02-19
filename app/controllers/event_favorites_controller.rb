class EventFavoritesController < ApplicationController
  def create
    event_favorite = EventFavorite.new(user_id: current_user.id, event_id: params[:id])
    if event_favorite.save
      respond_to do |format|
        format.js { render 'fav_destory.js', locals: { event_id: params[:id] } }
      end
    else
      flash[:alert] = '追加に失敗しました'
      redirect_back(fallback_location: root_path)
    end
  end

  def index
    @events = Event.where(id: current_user.event_favorites.pluck(:event_id))
    @events = Kaminari.paginate_array(@events).page(params[:page]).per(10)
  end

  def destroy
    event_favorite = EventFavorite.find_by(user_id: current_user.id, event_id: params[:id])
    if event_favorite.destroy
      respond_to do |format|
        format.js { render 'fav_create.js', locals: { event_id: params[:id] } }
      end
    else
      flash[:alert] = '削除に失敗しました'
      redirect_back(fallback_location: root_path)
    end
  end
end
