require 'rails_helper'


# 全てのテストは、test 環境のDBを空っぽの状態で行うこと。
# リファクタリング、渡す空の変数をクラス化して継承するようにしてしまえ
RSpec.describe 'Court', type: :system do
  describe "GET /index" do
    describe '場所検索機能' do
      before do
        FactoryBot.create(:user, id: 0)
        [*1..3].each do |n|
          FactoryBot.create(:area, id: n)
          FactoryBot.create(:court, user_id: 0, id: n, area_id: n)
          FactoryBot.create(:event, court_id: n, user_id: 0, id: n)
        end

      end
      context '入力：エリアid 1 存在するデータ：エリアid 1,2,3 のコートで開催されるイベント' do
        it 'エリア　id 1 のコートだけが返ってくる(2,3は返ってこない)' do
          visit events_path(court: {
            'open_time(1i)': '',
            'open_time(2i)': '',
            'open_time(3i)': '',
            'open_time(4i)': '',
            'open_time(5i)': '',
            'close_time(1i)': '',
            'close_time(2i)': '',
            'close_time(3i)': '',
            'close_time(4i)': '',
            'close_time(5i)': ''},
          Area: {
            area_ids: ["1"]
          }
          )
          expect(page).to have_content(Event.find(1).name)
          expect(page).not_to have_content(Event.find(2).name)&&have_content(Event.find(3).name)
        end
      end
    end

    describe '時間検索機能' do
      before do
        FactoryBot.create(:user, id: 0)
        FactoryBot.create(:court, user_id: 0, id: 0)
        [Time.new(2022,01,01,7,0),
         Time.new(2022,01,01,8,0),
         Time.new(2022,01,01,9,0)].each do |open_time|
          [Time.new(2022,01,01,10,0),
           Time.new(2022,01,01,11,0),
           Time.new(2022,01,01,12,0)].each do |close_time|
            FactoryBot.create(:event, open_time: open_time, close_time: close_time, court_id: 0, user_id: 0)
          end
        end
      end

      context '入力time 08:00~11:00 存在するデータ 7-10,7-11,7-12,8-10,8-11,8-12,9-10,9-11,9-12' do
        it '8-10,8-11,9-10,9-11のデータが返ってくる' do
          visit events_path(court: {
            'open_time(1i)': '2022',
            'open_time(2i)': '01',
            'open_time(3i)': '01',
            'open_time(4i)': '08',
            'open_time(5i)': '00',
            'close_time(1i)': '2022',
            'close_time(2i)': '01',
            'close_time(3i)': '01',
            'close_time(4i)': '11',
            'close_time(5i)': '00'}
          )
          expect(page).to have_content('2022年01月01日 08:00 ～ 2022年01月01日 10:00')&&\
                          have_content('2022年01月01日 08:00 ～ 2022年01月01日 11:00')&&\
                          have_content('2022年01月01日 09:00 ～ 2022年01月01日 10:00')&&\
                          have_content('2022年01月01日 09:00 ～ 2022年01月01日 11:00')
          expect(page).not_to have_content('2022年01月01日 07:00 ～ 2022年01月01日 10:00')&&\
                              have_content('2022年01月01日 07:00 ～ 2022年01月01日 11:00')&&\
                              have_content('2022年01月01日 07:00 ～ 2022年01月01日 12:00')&&\
                              have_content('2022年01月01日 08:00 ～ 2022年01月01日 12:00')&&\
                              have_content('2022年01月01日 09:00 ～ 2022年01月01日 12:00')
        end
      end
      context '入力なし、存在するデータ 7-10,7-11,7-12,8-10,8-11,8-12,9-10,9-11,9-12' do
        it 'すべて返ってくる' do
          visit events_path(court: {
            'open_time(1i)': '',
            'open_time(2i)': '',
            'open_time(3i)': '',
            'open_time(4i)': '',
            'open_time(5i)': '',
            'close_time(1i)': '',
            'close_time(2i)': '',
            'close_time(3i)': '',
            'close_time(4i)': '',
            'close_time(5i)': ''}
          )
          expect(page).to     have_content('2022年01月01日 07:00 ～ 2022年01月01日 10:00')&&\
                              have_content('2022年01月01日 07:00 ～ 2022年01月01日 11:00')&&\
                              have_content('2022年01月01日 07:00 ～ 2022年01月01日 12:00')&&\
                              have_content('2022年01月01日 08:00 ～ 2022年01月01日 10:00')&&\
                              have_content('2022年01月01日 08:00 ～ 2022年01月01日 11:00')&&\
                              have_content('2022年01月01日 08:00 ～ 2022年01月01日 12:00')&&\
                              have_content('2022年01月01日 09:00 ～ 2022年01月01日 10:00')&&\
                              have_content('2022年01月01日 09:00 ～ 2022年01月01日 11:00')&&\
                              have_content('2022年01月01日 09:00 ～ 2022年01月01日 12:00')
        end
      end
      context 'opentime 8~ のみ入力、存在するデータ 7-10,7-11,7-12,8-10,8-11,8-12,9-10,9-11,9-12' do
        it '7~ 以外のでーたは返ってくる' do
          visit events_path(court: {
          'open_time(1i)': '2022',
          'open_time(2i)': '01',
          'open_time(3i)': '01',
          'open_time(4i)': '08',
          'open_time(5i)': '00',
          'close_time(1i)': '',
          'close_time(2i)': '',
          'close_time(3i)': '',
          'close_time(4i)': '',
          'close_time(5i)': ''}
          )
          expect(page).to     have_content('2022年01月01日 08:00 ～ 2022年01月01日 10:00')&&\
                              have_content('2022年01月01日 08:00 ～ 2022年01月01日 11:00')&&\
                              have_content('2022年01月01日 08:00 ～ 2022年01月01日 12:00')&&\
                              have_content('2022年01月01日 09:00 ～ 2022年01月01日 10:00')&&\
                              have_content('2022年01月01日 09:00 ～ 2022年01月01日 11:00')&&\
                              have_content('2022年01月01日 09:00 ～ 2022年01月01日 12:00')
          expect(page).not_to have_content('2022年01月01日 07:00 ～ 2022年01月01日 10:00')&&\
                              have_content('2022年01月01日 07:00 ～ 2022年01月01日 11:00')&&\
                              have_content('2022年01月01日 07:00 ～ 2022年01月01日 12:00')
        end
      end
      context 'closetime ~11 のみ入力、存在するデータ 7-10,7-11,7-12,8-10,8-11,8-12,9-10,9-11,9-12' do
        it '~10 以外のでーたは返ってこない' do
          visit events_path(court: {
            'open_time(1i)': '',
            'open_time(2i)': '',
            'open_time(3i)': '',
            'open_time(4i)': '',
            'open_time(5i)': '',
            'close_time(1i)': '2022',
            'close_time(2i)': '01',
            'close_time(3i)': '01',
            'close_time(4i)': '11',
            'close_time(5i)': '00'}
          )
          expect(page).not_to     have_content('2022年01月01日 07:00 ～ 2022年01月01日 11:00')&&\
                              have_content('2022年01月01日 07:00 ～ 2022年01月01日 12:00')&&\
                              have_content('2022年01月01日 08:00 ～ 2022年01月01日 11:00')&&\
                              have_content('2022年01月01日 08:00 ～ 2022年01月01日 12:00')&&\
                              have_content('2022年01月01日 09:00 ～ 2022年01月01日 11:00')&&\
                              have_content('2022年01月01日 09:00 ～ 2022年01月01日 12:00')
          expect(page).to     have_content('2022年01月01日 07:00 ～ 2022年01月01日 10:00')&&\
                              have_content('2022年01月01日 08:00 ～ 2022年01月01日 10:00')&&\
                              have_content('2022年01月01日 09:00 ～ 2022年01月01日 10:00')
        end
      end
    end
  end
end