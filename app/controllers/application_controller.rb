class ApplicationController < ActionController::Base

  Lat_range = 0.03
  Lng_range = 0.06

  protect_from_forgery
  before_action :authenticate_user!, if: :needs_authentication?
  before_action :configure_permitted_parameters, if: :devise_controller?

  def fetch_geocoding_response(address)
    escaped_address = URI.encode_www_form_component(address)
    uri = URI("https://maps.googleapis.com/maps/api/geocode/json?address=#{escaped_address}&key=#{ENV['GOOGLEMAP_API_KEY']}&language=ja")

    req = Net::HTTP::Get.new(uri)
    res = nil
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |https|
       res = https.request(req)
    end
    return res
  end
  # sign in, sign out, log in 後はすべて root へ遷移
  protected
    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    end

  private
    def needs_authentication?
      return true if controller_name == "courts" && ["index","show","map_search"].all? {|elem| elem != action_name}
      return true if controller_name == "events" && (action_name != "index" && action_name != "show")
      return true if controller_name == "users"
    end
end
