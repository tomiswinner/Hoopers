class ApplicationController < ActionController::Base

# sign in, sign out, log in 後はすべて root へ遷移
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end
end
