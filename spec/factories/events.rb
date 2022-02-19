FactoryBot.define do
  factory :event do
    association :court
    association :user
    sequence(:name) { |n| "#{n}イベント" }
    image_id { 'aiueo' }
    description { 'address' }
    condition { 'url' }
    contact { '000-1111-1111' }
    open_time { Time.zone.now + rand(10..1000) }
    close_time { Time.zone.now + rand(100_000..1_000_000) }
    status { 1 }
  end
end
