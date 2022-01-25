require 'rails_helper'

RSpec.describe 'Court', type: :system do
  describe "GET /index" do
    describe '地区検索機能' do
      before do
        @factory_courts = FactoryBot.create_list(:court, 3)
      end
      context 'area_id = [ 1, 2 ] データ[ 1, 2, 3 ]なら', js: true do
        it 'area_id = 1 or 2 のコートのみが返ってくる' do
          visit courts_path
          click_on '絞り込み'
          select(@factory_courts[0].fetch_pref_name, from:'prefs_select')
          sleep 5
          puts page.html
          # check(Area.find(@factory_courts[0].area_id).name)
          # check(Area.find(@factory_courts[1].area_id).name)
          click_on('絞り込む')

          expect(@courts).to eq(Court.where(area_id: 1).or(Court.where(area_id: 2)))
        end
      end
      # 1,2,3の場合
      # ダミーデータ用意しないと

    end



    pending "add some examples (or delete) #{__FILE__}"
  end
end