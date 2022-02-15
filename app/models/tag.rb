class Tag < ApplicationRecord
  has_many :court_tag_taggings, dependent: :destroy

  validates :name           ,presence: true
end
