require 'rails_helper'

# 全てのテストは、test 環境のDBを空っぽの状態で行うこと。
# リファクタリング、渡す空の変数をクラス化して継承するようにしてしまえ
RSpec.describe 'Event', type: :system do
  describe 'GET /index' do
    describe '場所検索機能' do
      before do
        FactoryBot.create(:user, id: 0)
        @areas = []
        @courts = []
        @events = []
        [*1..3].each do |n|
          @areas[n - 1] = FactoryBot.create(:area, id: n)
          @courts[n - 1] = FactoryBot.create(:court, user_id: 0, id: n, area_id: n)
          @events[n - 1] = FactoryBot.create(:event, court_id: n, user_id: 0, id: n)
        end
      end

      context '入力：エリアid 1 存在するデータ：エリアid 1,2,3 のコートで開催されるイベント' do
        it 'エリア　id 1 のコートだけが返ってくる(2,3は返ってこない)' do
          visit events_path(event: {
                              'open_time(1i)': '',
                              'open_time(2i)': '',
                              'open_time(3i)': '',
                              'open_time(4i)': '',
                              'open_time(5i)': '',
                              'close_time(1i)': '',
                              'close_time(2i)': '',
                              'close_time(3i)': '',
                              'close_time(4i)': '',
                              'close_time(5i)': ''
                            },
                            prefectrue: {
                              id: @areas[0].prefecture_id
                            },
                            Area: {
                              area_ids: [@areas[0].id]
                            })
          expect(page).to have_content(Event.find(1).name)
          expect(page).not_to have_content(Event.find(2).name) && have_content(Event.find(3).name)
        end
      end
    end

    describe '県検索' do
      before do
        @event1 = FactoryBot.create(:event)
        @event2 = FactoryBot.create(:event)
      end

      it '県を選択すると、選択した県のイベントが表示される、それ以外は表示されない' do
        visit events_path(event: {
                            'open_time(1i)': '',
                            'open_time(2i)': '',
                            'open_time(3i)': '',
                            'open_time(4i)': '',
                            'open_time(5i)': '',
                            'close_time(1i)': '',
                            'close_time(2i)': '',
                            'close_time(3i)': '',
                            'close_time(4i)': '',
                            'close_time(5i)': ''
                          },
                          prefecture: {
                            id: @event1.court.area.prefecture.id
                          })
        expect(page).to have_content(@event1.name)
        expect(page).not_to have_content(@event2.name)
      end

      it '県を選択しない状態だと、何も表示されない' do
        visit events_path(event: {
                            'open_time(1i)': '',
                            'open_time(2i)': '',
                            'open_time(3i)': '',
                            'open_time(4i)': '',
                            'open_time(5i)': '',
                            'close_time(1i)': '',
                            'close_time(2i)': '',
                            'close_time(3i)': '',
                            'close_time(4i)': '',
                            'close_time(5i)': ''
                          },
                          prefecture: {
                            id: ''
                          })
        expect(page).not_to have_content(@event2.name) && have_content(@event1.name)
      end
    end

    describe '時間検索機能' do
      before do
        FactoryBot.create(:user, id: 0)
        [Time.zone.local(2022, 0o1, 0o1, 7, 0),
         Time.zone.local(2022, 0o1, 0o1, 8, 0),
         Time.zone.local(2022, 0o1, 0o1, 9, 0)].each do |open_time|
          [Time.zone.local(2022, 0o1, 0o1, 10, 0),
           Time.zone.local(2022, 0o1, 0o1, 11, 0),
           Time.zone.local(2022, 0o1, 0o1, 12, 0)].each do |close_time|
            FactoryBot.create(:event, open_time: open_time, close_time: close_time, user_id: 0)
          end
        end
      end

      context '入力time 08:00~11:00 存在するデータ 7-10,7-11,7-12,8-10,8-11,8-12,9-10,9-11,9-12' do
        it '8-10,8-11,9-10,9-11のデータが返ってくる' do
          visit events_path(event: {
                              'open_time(1i)': '2022',
                              'open_time(2i)': '01',
                              'open_time(3i)': '01',
                              'open_time(4i)': '08',
                              'open_time(5i)': '00',
                              'close_time(1i)': '2022',
                              'close_time(2i)': '01',
                              'close_time(3i)': '01',
                              'close_time(4i)': '11',
                              'close_time(5i)': '00'
                            })
          expect(page).to have_content('2022/01/01 08:00 ～ 2022/01/01 10:00') && \
                          have_content('2022/01/01 08:00 ～ 2022/01/01 11:00') && \
                          have_content('2022/01/01 09:00 ～ 2022/01/01 10:00') && \
                          have_content('2022/01/01 09:00 ～ 2022/01/01 11:00')
          expect(page).not_to have_content('2022/01/01 07:00 ～ 2022/01/01 10:00') && \
                              have_content('2022/01/01 07:00 ～ 2022/01/01 11:00') && \
                              have_content('2022/01/01 07:00 ～ 2022/01/01 12:00') && \
                              have_content('2022/01/01 08:00 ～ 2022/01/01 12:00') && \
                              have_content('2022/01/01 09:00 ～ 2022/01/01 12:00')
        end
      end

      context '入力なし、存在するデータ 7-10,7-11,7-12,8-10,8-11,8-12,9-10,9-11,9-12' do
        it 'すべて返ってくる' do
          visit events_path(event: {
                              'open_time(1i)': '',
                              'open_time(2i)': '',
                              'open_time(3i)': '',
                              'open_time(4i)': '',
                              'open_time(5i)': '',
                              'close_time(1i)': '',
                              'close_time(2i)': '',
                              'close_time(3i)': '',
                              'close_time(4i)': '',
                              'close_time(5i)': ''
                            })
          expect(page).to     have_content('2022/01/01 07:00 ～ 2022/01/01 10:00') && \
                              have_content('2022/01/01 07:00 ～ 2022/01/01 11:00') && \
                              have_content('2022/01/01 07:00 ～ 2022/01/01 12:00') && \
                              have_content('2022/01/01 08:00 ～ 2022/01/01 10:00') && \
                              have_content('2022/01/01 08:00 ～ 2022/01/01 11:00') && \
                              have_content('2022/01/01 08:00 ～ 2022/01/01 12:00') && \
                              have_content('2022/01/01 09:00 ～ 2022/01/01 10:00') && \
                              have_content('2022/01/01 09:00 ～ 2022/01/01 11:00') && \
                              have_content('2022/01/01 09:00 ～ 2022/01/01 12:00')
        end
      end

      context 'opentime 8~ のみ入力、存在するデータ 7-10,7-11,7-12,8-10,8-11,8-12,9-10,9-11,9-12' do
        it '7~ 以外のでーたは返ってくる' do
          visit events_path(event: {
                              'open_time(1i)': '2022',
                              'open_time(2i)': '01',
                              'open_time(3i)': '01',
                              'open_time(4i)': '08',
                              'open_time(5i)': '00',
                              'close_time(1i)': '',
                              'close_time(2i)': '',
                              'close_time(3i)': '',
                              'close_time(4i)': '',
                              'close_time(5i)': ''
                            })
          expect(page).to     have_content('2022/01/01 08:00 ～ 2022/01/01 10:00') && \
                              have_content('2022/01/01 08:00 ～ 2022/01/01 11:00') && \
                              have_content('2022/01/01 08:00 ～ 2022/01/01 12:00') && \
                              have_content('2022/01/01 09:00 ～ 2022/01/01 10:00') && \
                              have_content('2022/01/01 09:00 ～ 2022/01/01 11:00') && \
                              have_content('2022/01/01 09:00 ～ 2022/01/01 12:00')
          expect(page).not_to have_content('2022/01/01 07:00 ～ 2022/01/01 10:00') && \
                              have_content('2022/01/01 07:00 ～ 2022/01/01 11:00') && \
                              have_content('2022/01/01 07:00 ～ 2022/01/01 12:00')
        end
      end

      context 'closetime ~11 のみ入力、存在するデータ 7-10,7-11,7-12,8-10,8-11,8-12,9-10,9-11,9-12' do
        it '~10,11 以外のでーたは返ってこない' do
          visit events_path(event: {
                              'open_time(1i)': '',
                              'open_time(2i)': '',
                              'open_time(3i)': '',
                              'open_time(4i)': '',
                              'open_time(5i)': '',
                              'close_time(1i)': '2022',
                              'close_time(2i)': '01',
                              'close_time(3i)': '01',
                              'close_time(4i)': '11',
                              'close_time(5i)': '00'
                            })
          expect(page).not_to     have_content('2022/01/01 07:00 ～ 2022/01/01 12:00') && \
                                  have_content('2022/01/01 08:00 ～ 2022/01/01 12:00') && \
                                  have_content('2022/01/01 09:00 ～ 2022/01/01 12:00')
          expect(page).to         have_content('2022/01/01 07:00 ～ 2022/01/01 10:00') && \
                                  have_content('2022/01/01 07:00 ～ 2022/01/01 11:00') && \
                                  have_content('2022/01/01 08:00 ～ 2022/01/01 10:00') && \
                                  have_content('2022/01/01 08:00 ～ 2022/01/01 11:00') && \
                                  have_content('2022/01/01 09:00 ～ 2022/01/01 11:00') && \
                                  have_content('2022/01/01 09:00 ～ 2022/01/01 10:00')
        end
      end
    end

    describe '複合検索' do
      before do
        @area1 = FactoryBot.create(:area)
        @area2 = FactoryBot.create(:area)

        @court1 = FactoryBot.create(:court, area_id: @area1.id)
        @court2 = FactoryBot.create(:court, area_id: @area2.id)

        @event_ok = FactoryBot.create(:event,
                                      court_id: @court1.id,
                                      open_time: '2022/01/01 12:00',
                                      close_time: '2022/01/01 18:00',
                                      status: 'wanted')

        @event_ng = FactoryBot.create(:event,
                                      court_id: @court2.id,
                                      open_time: '2022/01/01 11:00',
                                      close_time: '2022/01/01 19:00',
                                      status: 'wanted')
      end

      context '存在するイベント全く同じ条件をいれれば' do
        it '同条件のイベントだけ返ってくる' do
          visit events_path(event: {
                              'open_time(1i)': '2022',
                              'open_time(2i)': '01',
                              'open_time(3i)': '01',
                              'open_time(4i)': '12',
                              'open_time(5i)': '00',
                              'close_time(1i)': '2022',
                              'close_time(2i)': '01',
                              'close_time(3i)': '01',
                              'close_time(4i)': '18',
                              'close_time(5i)': '00'
                            },
                            Area: {
                              area_ids: [@area1.id]
                            })
          expect(page).to have_content(@event_ok.name)
          expect(page).not_to have_content(@event_ng.name)
        end
      end
    end
  end
end
