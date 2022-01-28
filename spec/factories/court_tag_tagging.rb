FactoryBot.define do
  factory :court_tag_tagging do
    association :court
    association :tag
  end
end