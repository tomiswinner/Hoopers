require 'rails_helper'


# 全てのテストは、test 環境のDBを空っぽの状態で行うこと。
# リファクタリング、渡す空の変数をクラス化して継承するようにしてしまえ
RSpec.describe 'Court', type: :system do
  describe "GET /index" do

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
        end
        it '7-10,7-11,7-12,8-12,9-12のデータは返ってこない' do
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
          end
          it '7~ のデータは返ってこない' do
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
        end
        it '~10 のでーたは返ってくる' do
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
          expect(page).to     have_content('2022年01月01日 07:00 ～ 2022年01月01日 10:00')&&\
                              have_content('2022年01月01日 08:00 ～ 2022年01月01日 10:00')&&\
                              have_content('2022年01月01日 09:00 ～ 2022年01月01日 10:00')
        end
      end
    end
  end
end
      # context '入力open_time 12 close_time なし 存在データ 11~22,12~22,13~22,11~23,12~23,13~23,11~23:59,12~23:59,13~23:59' do
      #   it '12~,13~のデータは返ってくる' do
      #     visit events_path(court: {'open_time(4i)': '12', 'open_time(5i)': '00', 'close_time(4i)': '', 'close_time(5i)': ''})
      #     expect(page).to have_content('12:00 ～ 22:00')&&have_content('13:00 ～ 22:00')&&have_content('12:00 ～ 23:00')\
      #                                 &&have_content('13:00 ～ 23:00')&&have_content('12:00 ～ 23:59')&&have_content('13:00 ～ 23:59')
      #   end
      #   it '11 のデータは返ってこない'do
      #     visit events_path(court: {'open_time(4i)': '12', 'open_time(5i)': '00', 'close_time(4i)': '', 'close_time(5i)': ''})
      #     expect(page).not_to have_content('11:00 ～')
      #   end
      # end