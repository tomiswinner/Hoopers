FactoryBot.define do
  factory :court do
    association :user
    association :area
    sequence(:name) { |n| "#{n}コート"}
    image_id { 'aiueo' }
    sequence(:address) { |n| "#{n}-address" }
    latitude { 12.000 }
    longitude { 13.0000 }
    url { 'url' }
    open_time {}
    close_time {}
    supplement { 'なし' }
    size { 'なし' }
    price { 'なし' }
    court_type { 1 }
    business_status { true }
    confirmation_status { true }
  end
end
