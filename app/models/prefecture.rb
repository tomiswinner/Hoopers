class Prefecture < ApplicationRecord
  has_many :areas, dependent: :destroy
end
