FactoryBot.define do
  factory :area do
    association :prefecture
    sequence(:name) { |n| "#{n}町" }
  end
end
