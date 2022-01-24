require 'rails_helper'

RSpec.describe "Courts", type: :request do
  describe "GET /index" do
    describe '地区検索機能' do
      context 'area_id = [ 1, 2 ] なら' do
        it 'area_id = 1 or 2 のコートのみが返ってくる' do
          get courts_path, params: { area_id: [ '1', '2' ]}
          expect(@courts).to eq(Court.where(area_id: 1).or(Court.where(area_id: 2)))
        end
      end
      # 1,2,3の場合
      # ダミーデータ用意しないと
      
    end





    pending "add some examples (or delete) #{__FILE__}"
  end
end
