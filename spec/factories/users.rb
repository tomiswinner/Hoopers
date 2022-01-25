FactoryBot.define do
  factory :user do
    sequence(:name)  { |n| "#{n}太郎" }
    sequence(:email) { |n|  "hoge#{n}@example.com" }
    password { 'aiueoaiu' }

  end
end
