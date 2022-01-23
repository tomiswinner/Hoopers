# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'net/http'
require 'uri'
require 'json'

Resas_endpoint = 'https://opendata.resas-portal.go.jp'
Pref_path = '/api/v1/prefectures'
City_path = '/api/v1/cities'


def get_json(url)
  uri = URI.parse(url)

  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true


  param = {}
  param['X-API-KEY'] = ENV['RESAS_KEY']

  req = Net::HTTP::Get.new(uri.request_uri, param)
  res = https.request(req)

  json = res.body
  result = JSON.parse(json)

  return result
end


def register_prefecutres
  data = get_json(Resas_endpoint + Pref_path)

  data['result'].each do |val|
    Prefecture.create!(
      name: val['prefName']
      )
  end
end

def register_areas
  data = get_json(Resas_endpoint + City_path)

  data['result'].each do |val|
    Area.create!(
      prefecture_id: val['prefCode'],
      name: val['cityName']
      )
  end
end


# データを埋め込む際は、コメントアウト外す
# register_prefecutres
# register_areas