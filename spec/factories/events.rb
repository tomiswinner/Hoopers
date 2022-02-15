FactoryBot.define do
  factory :event do
    association :court
    association :user
    sequence(:name) { |n| "#{n}イベント"}
    image_id { 'aiueo' }
    description { 'address' }
    condition { 'url' }
    contact { '000-1111-1111' }
    open_time { Time.now()}
    close_time { Time.now() + rand(100000..1000000) }
    status { 1 }
  end
end
