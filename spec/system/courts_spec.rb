require 'rails_helper'


RSpec.describe 'Court', type: :system do
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
        [Court.convert_time_to_past_sec('11','00'),
         Court.convert_time_to_past_sec('12','00'),
         Court.convert_time_to_past_sec('13','00')].each do |open_time|
          [Court.convert_time_to_past_sec('22','00'),
           Court.convert_time_to_past_sec('23','00'),
           Court.convert_time_to_past_sec('23','59')].each do |close_time|
            FactoryBot.create(:court, open_time: open_time, close_time: close_time)
          end
        end
      end

      context '入力time 12:00~23:00 存在するデータ 11~22,12~22,13~22,11~23,12~23,13~23,11~23:59,12~23:59,13~23:59' do
        it '12~22,13~22,12~23,13~23のデータが返ってくる' do
          visit courts_path(Court: {'open_time(4i)': '12', 'open_time(5i)': '00', 'close_time(4i)': '23', 'close_time(5i)': '00'})
          # byebug
          expect(page).to have_content('12:00 ～ 22:00')&&have_content('13:00 ～ 22:00')&&('12:00 ～ 23:00')&&have_content('13:00 ～ 23:00')
        end
      end

      # context '入力open_time 12 存在データ 11,12,13なら' do
      #   it '12,13のデータが返ってくる' do
      #     visit courts_path(Court: {'open_time(4i)': '12', 'open_time(5i)': '00'})
      #     expect(page).to have_content('12:00')&&have_content("13:00")
      #   end
      #   it '11 のデータは返ってこない'do
      #     visit courts_path(Court: {'open_time(4i)': '12', 'open_time(5i)': '00'})
      #     expect(page).not_to have_content('11:00')
      #   end
      # end


    end
  end
end