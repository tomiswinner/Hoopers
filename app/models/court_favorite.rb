class CourtFavorite < ApplicationRecord
  belongs_to :court
  belongs_to :user
end
