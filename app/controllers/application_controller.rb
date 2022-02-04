class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  def fetch_geocoding_response(address)
    escaped_address = URI.encode_www_form_component(address)
    uri = URI("https://maps.googleapis.com/maps/api/geocode/json?address=#{escaped_address}&key=#{ENV['GOOGLEMAP_API_KEY']}")

    req = Net::HTTP::Get.new(uri)
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |https|
      @res = https.request(req)
      puts @res
    end

    return @res
  end
  # sign in, sign out, log in 後はすべて root へ遷移
  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end
end
