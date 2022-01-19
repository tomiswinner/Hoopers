class Area < ApplicationRecord
  belongs_to :prefecture

  has_many :courts, dependent: :destroy
end
