class CourtFavoritesController < ApplicationController
  def create; end

  def index
    @courts = Court.where(id: current_user.court_favorites.pluck(:court_id))
  end

  def destroy; end
end
