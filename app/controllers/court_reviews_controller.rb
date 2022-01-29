class CourtReviewsController < ApplicationController
  def new
    @court_review = CourtReview.new()
  end

  def create; end

  def index
    @court = Court.find(params[:court_id])
    @court_reviews = @court.court_reviews
  end

  def edit; end

  def update; end
end
