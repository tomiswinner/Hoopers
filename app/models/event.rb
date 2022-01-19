class Event < ApplicationRecord
  belongs_to :user
  belongs_to :court

  has_many :event_favorites, dependent: :destroy
  has_many :event_histories, dependent: :destroy
end
