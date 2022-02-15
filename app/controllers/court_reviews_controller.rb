class CourtReviewsController < ApplicationController
  def new
    @court_review = CourtReview.new()
  end

  def create
    @court_review = CourtReview.new(court_review_params)
    @court_review.calc_total_points()

    if @court_review.save
      flash[:notice] = 'レビューが投稿されました！'
      redirect_to court_path(@court_review.court_id)
    else
      flash.now[:alert] = "レビュー投稿に失敗しました\n入力のない値があるか、既にレビューが投稿されています。"
      render :new
    end
  end

  def index
    @court = Court.find(params[:court_id])
    @court_reviews = @court.court_reviews
    if user_signed_in?
      @user_review = CourtReview.find_by(user_id: current_user.id, court_id: @court.id)
    end
  end

  def edit
    @court_review = CourtReview.find(params[:id])
  end

  def update
    @court_review = CourtReview.find(params[:id])
    @court_review.assign_attributes(court_review_params)
    @court_review.calc_total_points

    if @court_review.save
      flash[:notice] = 'レビューが修正されました！'
      redirect_to court_path(@court_review.court_id)
    else
      flash.now[:alert] = 'レビュー修正に失敗しました'
      render :edit
    end

  end

  private
    def court_review_params
      params.require(:court_review).permit(:accessibility, :security, :quality, :court_id, :user_id)
    end
end
