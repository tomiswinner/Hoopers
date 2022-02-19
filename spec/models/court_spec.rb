require 'rails_helper'

RSpec.describe Court, type: :model do
  describe 'convert_time_to_past_mins'
  before(:all) do
    FactoryBot.create(:court, :open_time)
  end

  pending "add some examples to (or delete) #{__FILE__}"
end
