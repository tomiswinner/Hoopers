FactoryBot.define do
  factory :prefecture do
    sequence(:name) { |n| "#{n}県" }
  end
end
