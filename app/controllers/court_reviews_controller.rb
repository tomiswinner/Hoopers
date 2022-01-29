class CourtReviewsController < ApplicationController
  def new
    @court_review = CourtReview.new()
  end

  def create
    @court_review = CourtReview.new(court_review_params)
    if @court_review.save
      flash.now[:notice] = 'レビューが投稿されました！'
      redirect_to court_path(@court_review.court_id)
    else
      flash.now[:alert] = 'レビュー投稿に失敗しました'
      render :new
    end
  end

  def index
    @court = Court.find(params[:court_id])
    @court_reviews = @court.court_reviews
  end

  def edit; end

  def update; end

  private
    def court_review_params
      params.require(:court_review).permit(:accessibility, :security, :quality, :court_id, :user_id)
    end
end
