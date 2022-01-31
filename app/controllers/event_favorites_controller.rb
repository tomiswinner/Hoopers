class EventFavoritesController < ApplicationController
  def create
    event_favorite = EventFavorite.new(user_id: current_user.id, event_id: params[:id])
    if event_favorite.save
      flash.now[:notice] = '検討リストに追加されました'
      # create,destroy の redirect 先どうしよう。
    else
      flash.now[:alert] = '追加に失敗しました'
    end

  end

  def index
    @events = Event.where(id: current_user.event_favorites.pluck(:event_id))
  end

  def destroy
    event_favorite = EventFavorite.new(user_id: current_user.id, event_id: params[:id])
    if event_favorite.destroy
      flash.now[:notice] = '検討リストから削除されました'
    else
      flash.now[:alert] = '削除に失敗しました'
    end
  end
end
