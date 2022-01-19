class CourtTagTagging < ApplicationRecord
  belongs_to :court
  belongs_to :tag
end
