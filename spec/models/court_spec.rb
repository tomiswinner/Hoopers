require 'rails_helper'

RSpec.describe Court, type: :model do
  describe 'convert_time_to_past_mins'
  before(:each) do
    @court = FactoryBot.create(:court, :open_time)
  end
  it '' do
    expect(@court.convert_time_to_past_sec(1, 30)).to eq(1 * 60 * 60 + 30 * 60)
  end

  pending "add some examples to (or delete) #{__FILE__}"
end
