class CourtReviewsController < ApplicationController
  def new
    @court_review = CourtReview.new()
  end

  def create; end

  def index
    @court = Court.find(params[:court_id])
    @court_reviews = @court.court_reviews
  end

  def edit
    @user = current_user
  end

  def confirm
    @user = current_user
  end

  def update
    @customer = current_customer

    if params[:is_deactivation?]
      @user.update(is_active: false)
      flash[:notice] = "退会処理が完了しました。"
      sign_out_and_redirect(current_user)

    else
      if @customer.update(customer_params)
        flash[:notice] = "更新が完了しました"
        redirect_to user_mypage_path

      else
        flash[:alert] = "更新に失敗しました"
        render :edit
      end
    end
  end

  private
    def user_params
      param.require(:user).permit(:name, :email)
    end
end
