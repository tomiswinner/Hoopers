require 'rails_helper'


RSpec.describe 'Court', type: :system do
  after(:suite) do
  end
  describe "GET /index" do
    describe '地区検索機能' do
      before(:all) do
        @factory_courts = FactoryBot.create_list(:court, 3)
      end
      after(:all) do
      end
      context 'area_id = [ 1, 2 ] 存在するデータのidが[ 1, 2, 3 ]なら' do
        it 'area_id = 1 or 2 のコートが返ってくる' do
          visit courts_path(Area: {area_ids: [ @factory_courts[0].area_id, @factory_courts[1].area_id ]})
          expect(page).to have_content(@factory_courts[0].name)&&have_content(@factory_courts[1].name)
        end
        it 'area_id = 3 のコートは返ってこない' do
          visit courts_path(Area: {area_ids: [ @factory_courts[0].area_id, @factory_courts[1].area_id ]})
          expect(page).not_to have_content(@factory_courts[2].name)
        end
      end
      context 'area_id = [] 存在するデータ[ 1, 2, 3 ]なら' do
        it '一致するコートがありませんと表示される' do
          visit courts_path
          puts page.html
          expect(page).to have_content('一致するコートがありません')
        end
      end
    end
    describe '時間検索機能' do
      before(:all) do
        ['11:00','12:00','13:00'].each do |open|
          ['22:00','23:00','24:00'].each do |close|
            FactoryBot.create(:court, open_time: opne, close_time: close)
          end
        end
      end

      context '入力time 12:00~23:00 存在するデータ 11~22,12~22,13~22,11~23,12~23,13~23,11~24,12~24,13~24' do
        it '12~22,13~22,12~23,13~23のデータが返ってくる' do
          visit courts_path
          expect(page).to have_content('address')
        end
      end
    end
    
  end
end