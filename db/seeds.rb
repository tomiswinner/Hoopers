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


def register_test_user
   User.create!(
     id: 0,
     name: 'test_user',
     email: 'hogehogee@example.com',
     password: 'hogehoge'
     )
end

def register_dummy_courts
  10.times{
    area_id = rand(Area.first.id..Area.last.id)
    address = Area.find(area_id).name
    Court.create!(
      user_id: 0,
      area_id: area_id,
      name: address + 'バスケ' + 'コート',
      image_id: 'hoge',
      address: address,
      latitude: rand(-90.0000..90.0000),
      longitude: rand(-180.0000..180.0000),
      url: 'なし',
      supplement: 'なし',
      size: '確認中',
      price: '確認中',
      court_type: rand(1..5),
      bussiness_status: true,
      confirmation_status: false
      )
  }
end

def register_tags
  ['個人利用OK', '子供も安心', 'ミニバスリングあり', '駐車場あり', 'ボールレンタルOK',
   '団体利用OK', '初心者安心', '予約不要', '予約可能'].each do |tag_name|
    Tag.create!({
      name: tag_name
    })
   end

end


# データを埋め込む際は、コメントアウト外す
# register_prefecutres
# register_areas
# register_test_user
# register_dummy_courts
# register_tags

