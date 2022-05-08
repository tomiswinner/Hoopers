class Geocode
  def initialize(address)
    @address = address
  end

  def fetch
    uri = build_uri
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |https|
      res = https.request(uri)
    end
  end

  private
  def build_uri
    escaped_address = URI.encode_www_form_component(@address)
    URI("https://maps.googleapis.com/maps/api/geocode/json?address=#{escaped_address}&key=#{ENV['GOOGLE_API_KEY_GEOCODE']}&language=ja")
  end
end
