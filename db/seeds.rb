# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

RESAS_ENDPOINT = 'https://opendata.resas-portal.go.jp'
PREF_PATH = '/api/v1/prefectures'
CITY_PATH = '/api/v1/cities'


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


def register_prefectures
  data = get_json(RESAS_ENDPOINT + PREF_PATH)

  data['result'].each do |val|
    Prefecture.create!(
      name: val['prefName']
      )
  end
end

def register_areas
  data = get_json(RESAS_ENDPOINT + CITY_PATH)

  data['result'].each do |val|
    Area.create!(
      prefecture_id: val['prefCode'],
      name: val['cityName']
      )
  end
end


def register_admin_user
   User.create!(
     id: 0,
     name: 'admin_user',
     email: ENV['ADMIN_EMAIL'],
     password: ENV['ADMIN_PASS']
     )
end

def register_tags
  ['個人利用OK', '子供も安心', 'ミニバスリングあり', '駐車場あり', 'ボールレンタルOK',
   '団体利用OK', '初心者安心', '予約不要', '予約可能'].each do |tag_name|
    Tag.create!({
      name: tag_name
    })
   end
end

def register_dummy_courts
  10.times do |n|
    area_id = rand(Area.first.id..Area.last.id)
    address = Area.find(area_id).name
    Court.create!(
      user_id: 0,
      area_id: area_id,
      name: "#{address}コート",
      image_id: "aa",
      address: address,
      latitude: rand(-90.0000..90.0000),
      longitude: rand(-180.0000..180.0000),
      open_time: n * 3600,
      close_time: n * 2 * 3600,
      url: 'なし',
      supplement: 'なし',
      size: '確認中',
      price: '確認中',
      court_type: rand(1..5),
      business_status: [true,true,true,false].sample,
      confirmation_status: [true,true,true,false].sample
      )
  end
end

def register_dummy_reviews
  Court.all.each do |court|
    CourtReview.create!(
      court_id: court.id,
      user_id: 0,
      accessibility: 3.5,
      security: 4,
      quality: 4.5,
      total_points: [3.5,4.0,4.5].sum.fdiv(3)
      )
  end
end

def register_dummy_taggings
  10.times do |n|
    CourtTagTagging.create!({
      court_id: Court.find(n + 1).id,
      tag_id: rand(Tag.first.id..Tag.last.id)
    })
  end
end

def register_dummy_events
  Court.all.each do |court|
    open_time = Time.now - rand(1..10) * 50000
    Event.create!(
      court_id: court.id,
      name: "#{court.name}ピック",
      user_id: 0,
      image_id: 'aa',
      condition: '10000円　ボール持参',
      description: 'あああああああああああああ',
      contact: '123-456-7189',
      open_time: open_time,
      close_time: open_time + rand(1..10) * 30000,
      status: [1, 1, 1, 0].sample
      )
    end
end

def register_dummy_court_favs
  Court.all.each do |court|
    if [true,true,false].sample
    CourtFavorite.create!(
      court_id: court.id,
      user_id: 0
      )
    end
  end
end


# データを埋め込む際は、コメントアウト外す
register_prefectures
register_areas
register_admin_user
register_tags
# register_dummy_courts
# register_dummy_taggings
# register_dummy_reviews
# register_dummy_events
# register_dummy_court_favs



