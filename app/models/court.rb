class Court < ApplicationRecord
  belongs_to :user
  belongs_to :area

  has_many :events,             dependent: :destroy
  has_many :court_reviews,      dependent: :destroy
  has_many :court_favorites,    dependent: :destroy
  has_many :court_histories,    dependent: :destroy
  has_many :court_tag_taggings, dependent: :destroy
  has_many :users,                through: :court_favorites
  has_many :users,                through: :court_histories
  has_many :tags,                 through: :court_tag_taggings
end
