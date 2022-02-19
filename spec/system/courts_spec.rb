require 'rails_helper'

# 全てのテストは、test 環境のDBを空っぽの状態で行うこと。
# リファクタリング、渡す空の変数をクラス化して継承するようにしてしまえ
RSpec.describe 'Court', type: :system do
  describe 'GET /index' do
    describe '表示機能' do
      before do
        @court1 = FactoryBot.create(:court, business_status: true, confirmation_status: true)
        @court2 = FactoryBot.create(:court, business_status: true, confirmation_status: false)
        @court3 = FactoryBot.create(:court, business_status: false, confirmation_status: true)
        @court4 = FactoryBot.create(:court, business_status: false, confirmation_status: false)
      end

      context '検索結果ページに何のparamsもなく来た時' do
        it 'エラーが発生せず、confirmation_status: true ,business_status: true のコートが表示される' do
          visit courts_path
          expect(page).to have_content(@court1.name)
        end

        it 'エラーが発生せず、confirmation_status: true ,business_status: true 以外のコートは表示されない' do
          visit courts_path
          expect(page).not_to have_content(@court2.name) && have_content(@court3.name) && have_content(@court4.name)
        end
      end
    end

    describe '地区検索機能' do
      before do
        @factory_courts = FactoryBot.create_list(:court, 3)
      end

      context 'area_id = [ 1, 2 ] 存在するデータのidが[ 1, 2, 3 ]なら' do
        it 'area_id = 1 と 2 のコートが返ってくる' do
          visit courts_path(
            Area: { area_ids: [@factory_courts[0].area_id, @factory_courts[1].area_id] },
            court: { 'open_time(4i)': '', 'open_time(5i)': '', 'close_time(4i)': '', 'close_time(5i)': '' }
          )
          expect(page).to have_content(@factory_courts[0].name) && have_content(@factory_courts[1].name)
        end

        it 'area_id = 3 のコートは返ってこない' do
          visit courts_path(Area: { area_ids: [@factory_courts[0].area_id, @factory_courts[1].area_id] },
                            court: { 'open_time(4i)': '', 'open_time(5i)': '',
                                     'close_time(4i)': '', 'close_time(5i)': '' })
          expect(page).not_to have_content(@factory_courts[2].name)
        end
      end

      context 'area_id = [4] 存在するデータ[ 1, 2, 3 ]なら' do
        it '一致するコートがありませんと表示される' do
          visit courts_path(
            Area: { area_ids: [4] },
            court: { 'open_time(4i)': '', 'open_time(5i)': '', 'close_time(4i)': '', 'close_time(5i)': '' }
          )
          expect(page).to have_content('一致するコートがありません')
        end
      end
    end

    describe '時間検索機能' do
      before do
        [Court.convert_time_to_past_sec('11', '00'),
         Court.convert_time_to_past_sec('12', '00'),
         Court.convert_time_to_past_sec('13', '00')].each do |open_time|
          [Court.convert_time_to_past_sec('22', '00'),
           Court.convert_time_to_past_sec('23', '00'),
           Court.convert_time_to_past_sec('23', '59')].each do |close_time|
            FactoryBot.create(:court, open_time: open_time, close_time: close_time)
          end
        end
        @court = FactoryBot.create(:court, open_time: nil, close_time: nil, business_status: true,
                                           confirmation_status: true)
      end

      context '入力time 12:00~23:00 存在するデータ 11~22,12~22,13~22,11~23,12~23,13~23,11~23:59,12~23:59,13~23:59' do
        it '12~22,13~22,12~23,13~23のデータが返ってくる' do
          visit courts_path(court: { 'open_time(4i)': '12', 'open_time(5i)': '00', 'close_time(4i)': '23',
                                     'close_time(5i)': '00' })
          expect(page).to have_content('12:00 ～ 22:00') && have_content('13:00 ～ 22:00') && '12:00 ～ 23:00' && have_content('13:00 ～ 23:00')
        end
      end

      context '入力open_time 12 close_time なし 存在データ 11~22,12~22,13~22,11~23,12~23,13~23,11~23:59,12~23:59,13~23:59' do
        it '12~,13~のデータは返ってくる' do
          visit courts_path(court: { 'open_time(4i)': '12', 'open_time(5i)': '00', 'close_time(4i)': '',
                                     'close_time(5i)': '' })
          expect(page).to have_content('12:00 ～ 22:00') && have_content('13:00 ～ 22:00') && have_content('12:00 ～ 23:00')\
                                      &&have_content('13:00 ～ 23:00') && have_content('12:00 ～ 23:59') && have_content('13:00 ～ 23:59')
        end

        it '11 のデータは返ってこない' do
          visit courts_path(court: { 'open_time(4i)': '12', 'open_time(5i)': '00', 'close_time(4i)': '',
                                     'close_time(5i)': '' })
          expect(page).not_to have_content('11:00 ～')
        end
      end

      context '入力close_time 23 close_time なし 存在データ 11~22,12~22,13~22,11~23,12~23,13~23,11~23:59,12~23:59,13~23:59' do
        it '~22,~23のデータは返ってくる' do
          visit courts_path(court: { 'open_time(4i)': '', 'open_time(5i)': '', 'close_time(4i)': '23',
                                     'close_time(5i)': '00' })
          expect(page).to have_content('11:00 ～ 22:00') && have_content('12:00 ～ 22:00') && have_content('13:00 ～ 22:00')\
                                      &&have_content('11:00 ～ 23:00') && have_content('12:00 ～ 23:00') && have_content('13:00 ～ 23:00')
        end

        it '23:59 のデータは返ってこない' do
          visit courts_path(court: { 'open_time(4i)': '', 'open_time(5i)': '', 'close_time(4i)': '23',
                                     'close_time(5i)': '00' })
          expect(page).not_to have_content('～ 23:59')
        end
      end

      context '入力 12~23存在データ null~null' do
        it 'nullコートは返ってこない' do
          visit courts_path(court: {
                              'open_time(4i)': '12',
                              'open_time(5i)': '00',
                              'close_time(4i)': '23',
                              'close_time(5i)': '00'
                            })
          expect(page).not_to have_content(@court.name.to_s)
        end
      end
    end

    describe 'コートタイプ検索機能' do
      before do
        @court_types = Court.court_types.keys
        @courts = []
        Court.court_types.keys.each_with_index do |court_type, i|
          @courts[i] = FactoryBot.create(:court, court_type: court_type)
        end
      end

      context '入力コートタイプがkey[0],key[1]  データkey[0]~[4]のコートがあるなら' do
        it 'key[0],key[1]のコートが返ってくる' do
          visit courts_path(court: { court_types: [@court_types[0], @court_types[1]], 'open_time(4i)': '',
                                     'open_time(5i)': '', 'close_time(4i)': '', 'close_time(5i)': '' })
          # byebug
          expect(page).to have_content(@courts[0].name) && have_content(@courts[1].name)
        end
      end
    end

    describe 'タグ検索機能' do
      before do
        @courts =
          3.times do |_n|
            FactoryBot.create(:court)
            FactoryBot.create(:tag)
          end
        FactoryBot.create(:court_tag_tagging, court_id: Court.first.id, tag_id: Tag.first.id)
        FactoryBot.create(:court_tag_tagging, court_id: Court.first.id, tag_id: Tag.second.id)
        FactoryBot.create(:court_tag_tagging, court_id: Court.second.id, tag_id: Tag.first.id)
        FactoryBot.create(:court_tag_tagging, court_id: Court.second.id, tag_id: Tag.third.id)
        FactoryBot.create(:court_tag_tagging, court_id: Court.third.id, tag_id: Tag.second.id)
        FactoryBot.create(:court_tag_tagging, court_id: Court.third.id, tag_id: Tag.third.id)
      end

      context ' 0,1 のタグをもつデータ、0,2のタグをもつデータ, 1,2のタグをもつデータ'
      it '入力tag 0,1　でデータ(0,1)は返ってくる' do
        visit courts_path(Tag: { tag_ids: [Tag.first.id, Tag.second.id] },
                          court: { 'open_time(4i)': '', 'open_time(5i)': '',
                                   'close_time(4i)': '', 'close_time(5i)': '' })
        expect(page).to have_content(Court.first.name)
      end

      it '入力tag 0,1　でデータ(0,2)(1,2)は返ってこない' do
        visit courts_path(Tag: { tag_ids: [Tag.first.id, Tag.second.id] },
                          court: { 'open_time(4i)': '', 'open_time(5i)': '',
                                   'close_time(4i)': '', 'close_time(5i)': '' })
        expect(page).not_to have_content(Court.second.name) && have_content(Court.third.name)
      end

      it '入力tag 0 でデータ(0,1),(0,2)ｇ返ってくる' do
        visit courts_path(Tag: { tag_ids: [Tag.first.id] },
                          court: { 'open_time(4i)': '', 'open_time(5i)': '',
                                   'close_time(4i)': '', 'close_time(5i)': '' })
        expect(page).to have_content(Court.first.name) && have_content(Court.second.name)
      end

      it '入力tag 0 でデータ(1,2)は返ってこない' do
        visit courts_path(Tag: { tag_ids: [Tag.first.id] },
                          court: { 'open_time(4i)': '', 'open_time(5i)': '',
                                   'close_time(4i)': '', 'close_time(5i)': '' })
        expect(page).not_to have_content(Court.third.name)
      end
    end

    describe 'マップ検索' do
      CENTER_LAT = 35.4762362
      CENTER_LNG = 139.6369951
      LAT_RANGE = 0.05
      LNG_RANGE = 0.05
      before do
        @user = FactoryBot.create(:user, id: 0)
        prefecture = FactoryBot.create(:prefecture, name: '神奈川県')
        area = FactoryBot.create(:area, prefecture_id: prefecture.id)
        @court_ok1 = FactoryBot.create(:court, user_id: @user.id, latitude: CENTER_LAT + LAT_RANGE,
                                               longitude: CENTER_LNG + LNG_RANGE, area_id: area.id)
        @court_ok2 = FactoryBot.create(:court, user_id: @user.id, latitude: CENTER_LAT + LAT_RANGE,
                                               longitude: CENTER_LNG - LNG_RANGE, area_id: area.id)
        @court_ok3 = FactoryBot.create(:court, user_id: @user.id, latitude: CENTER_LAT - LAT_RANGE,
                                               longitude: CENTER_LNG + LNG_RANGE, area_id: area.id)
        @court_ok4 = FactoryBot.create(:court, user_id: @user.id, latitude: CENTER_LAT - LAT_RANGE,
                                               longitude: CENTER_LNG - LNG_RANGE, area_id: area.id)
      end

      it 'court_okはすべて返ってくる' do
        login_as(@user)
        visit address_courts_path
        page.find(:id, 'court_address').set('神奈川県横浜市神奈川区東神奈川2-49-7')
        click_button('検索')
        expect(find(:id, "#{@court_ok1.name}_name", visible: false).value).to eq(@court_ok1.name.to_s)
        expect(find(:id, "#{@court_ok2.name}_name", visible: false).value).to eq(@court_ok2.name.to_s)
        expect(find(:id, "#{@court_ok3.name}_name", visible: false).value).to eq(@court_ok3.name.to_s)
        expect(find(:id, "#{@court_ok4.name}_name", visible: false).value).to eq(@court_ok4.name.to_s)
      end
    end

    describe '複合検索' do
      before do
        @area1 = FactoryBot.create(:area)
        @area2 = FactoryBot.create(:area)
        @court_type1 = Court.court_types.keys[1]
        @court_type2 = Court.court_types.keys[2]
        @tag1 = FactoryBot.create(:tag)
        @tag2 = FactoryBot.create(:tag)

        @court_ok = FactoryBot.create(:court,
                                      area_id: @area1.id,
                                      open_time: Court.convert_time_to_past_sec('11', '00'),
                                      close_time: Court.convert_time_to_past_sec('22', '00'),
                                      court_type: @court_type1,
                                      business_status: true,
                                      confirmation_status: true)
        @court_ng = FactoryBot.create(:court,
                                      area_id: @area2.id,
                                      open_time: Court.convert_time_to_past_sec('11', '00'),
                                      close_time: Court.convert_time_to_past_sec('22', '00'),
                                      court_type: @court_type1,
                                      business_status: true,
                                      confirmation_status: true)

        FactoryBot.create(:court_tag_tagging, court_id: @court_ok.id, tag_id: @tag1.id)
      end

      context '存在するコートと全く一緒の条件をいれれば' do
        it '同条件のコートだけが返ってくる' do
          visit courts_path(
            Area: { area_ids: [@area1.id] },
            Tag: { tag_ids: [@tag1.id] },
            court: { court_types: [@court_type1],
                     'open_time(4i)': '11', 'open_time(5i)': '00', 'close_time(4i)': '22', 'close_time(5i)': '00' }
          )
          expect(page).to have_content(@court_ok.name)
          expect(page).not_to have_content(@court_ng.name)
        end
      end
    end
  end
end
