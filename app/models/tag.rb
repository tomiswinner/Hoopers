class Tag < ApplicationRecord
  has_many :court_tag_taggings, dependent: :destroy
  has_many :courts, through: :court_tag_taggings
end
