class ApplicationController < ActionController::Base
  LAT_RANGE = 0.1
  LNG_RANGE = 0.1

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

  def latlng_search(courts, lat, lng)
    courts = courts.where('? <= latitude', lat - LAT_RANGE).where('? >= latitude', lat + LAT_RANGE)
    courts = courts.where('? <= longitude', lng - LNG_RANGE).where('? >= longitude', lng + LNG_RANGE)
    return courts
  end

  def return_latlng(geocoded_data)
    location = geocoded_data['results'][0]['geometry']['location']
    return location['lat'], location['lng']
  end

  def area_search(courts, area_ids)
    results = Court.none
    area_ids.each do |area_id|
      results = results.or(courts.where(area_id: area_id))
    end
    return results
  end

  def register_refile_from_confirmation(instance, refile_id)
    return instance if refile_id.empty?
    refile_obj = Refile.backends['cache'].get(refile_id)
    instance.image = Refile.backends['store'].upload(refile_obj)
    return instance
  end

  # sign in, sign out, log in 後はすべて root へ遷移
  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  def valid_request?(res)
    return !(res.nil?) && res.message == 'OK' && JSON.parse(res.body) == 'OK'
  end

  private

  # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
  def needs_authentication?
    return true if controller_name == 'courts' && %w[index show map_search].all? { |elem| elem != action_name }
    return true if controller_name == 'events' && (action_name != 'index' && action_name != 'show')
    return true if controller_name == 'court_reviews' && action_name != 'index'
    return true if %w[users court_favorites court_histories event_favorites event_histories
                      court_infos].include?(controller_name)
  end
  # rubocop:enable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity

  def valid_pref_key?(pref_id)
    return true if pref_id.nil?

    return unless pref_id.empty?

    flash[:alert] = '県が選択されていません'
    redirect_back(fallback_location: root_path)
  end
end
