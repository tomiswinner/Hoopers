FactoryBot.define do
  factory :tag do
    sequence(:name) {|n| "example#{n}"}

  end


end