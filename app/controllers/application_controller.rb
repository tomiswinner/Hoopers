class ApplicationController < ActionController::Base

  Lat_range = 0.03
  Lng_range = 0.06

  before_action :configure_permitted_parameters, if: :devise_controller?

  def fetch_geocoding_response(address)
    escaped_address = URI.encode_www_form_component(address)
    uri = URI("https://maps.googleapis.com/maps/api/geocode/json?address=#{escaped_address}&key=#{ENV['GOOGLEMAP_API_KEY']}")

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
end
