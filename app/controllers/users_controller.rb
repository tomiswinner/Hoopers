class UsersController < ApplicationController
  def mypage
    @user = current_user
  end

  def edit
    @user = current_user
  end

  def events
    @events = Event.where(user_id: current_user.id)
    @events = Kaminari.paginate_array(@events).page(params[:page]).per(10)
  end

  def update
     @user = current_user

    if params[:is_deactivation?]
      @user.update(is_active: false)
      flash[:notice] = "退会処理が完了しました。"
      sign_out_and_redirect(current_user)

    else
      if @user.update(user_params)
        flash[:notice] = "更新が完了しました"
        redirect_to mypage_users_path

      else
        flash[:alert] = "更新に失敗しました"
        render :edit
      end
    end
  end

  def confirm
      @user = current_user
  end

  private
    def user_params
      params.require(:user).permit(:name, :email)
    end
end
