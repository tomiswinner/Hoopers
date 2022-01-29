require 'rails_helper'


# 全てのテストは、test 環境のDBを空っぽの状態で行うこと。
# リファクタリング、渡す空の変数をクラス化して継承するようにしてしまえ
RSpec.describe 'Court', type: :system do
  describe "GET /index" do
    describe '地区検索機能' do
      before do
        @factory_courts = FactoryBot.create_list(:court, 3)
      end
      context 'area_id = [ 1, 2 ] 存在するデータのidが[ 1, 2, 3 ]なら' do
        it 'area_id = 1 と 2 のコートが返ってくる' do
          visit courts_path(Area: {area_ids: [ @factory_courts[0].area_id, @factory_courts[1].area_id ]}, court: {court_types: [""], 'open_time(4i)': '', 'open_time(5i)': '', 'close_time(4i)': '', 'close_time(5i)': ''})
          expect(page).to have_content(@factory_courts[0].name)&&have_content(@factory_courts[1].name)
        end
        it 'area_id = 3 のコートは返ってこない' do
          visit courts_path(Area: {area_ids: [ @factory_courts[0].area_id, @factory_courts[1].area_id ]}, court: {court_types: [""], 'open_time(4i)': '', 'open_time(5i)': '', 'close_time(4i)': '', 'close_time(5i)': ''})
          expect(page).not_to have_content(@factory_courts[2].name)
        end
      end
      context 'area_id = [] 存在するデータ[ 1, 2, 3 ]なら' do
        it '一致するコートがありませんと表示される' do
          visit courts_path(court: {court_types: [""], 'open_time(4i)': '', 'open_time(5i)': '', 'close_time(4i)': '', 'close_time(5i)': ''})
          pending('仕様上、検索条件が与えられなかった場合、全ての一覧を返すようになったので、後ほど修正')
          expect(page).to have_content('一致するコートがありません')
        end
      end
    end

    describe '時間検索機能' do
      before do
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
          visit courts_path(court: {'open_time(4i)': '12', 'open_time(5i)': '00', 'close_time(4i)': '23', 'close_time(5i)': '00', court_types: [""]})
          expect(page).to have_content('12:00 ～ 22:00')&&have_content('13:00 ～ 22:00')&&('12:00 ～ 23:00')&&have_content('13:00 ～ 23:00')
        end
      end

      context '入力open_time 12 close_time なし 存在データ 11~22,12~22,13~22,11~23,12~23,13~23,11~23:59,12~23:59,13~23:59' do
        it '12~,13~のデータは返ってくる' do
          visit courts_path(court: {'open_time(4i)': '12', 'open_time(5i)': '00', 'close_time(4i)': '', 'close_time(5i)': '', court_types: [""]})
          expect(page).to have_content('12:00 ～ 22:00')&&have_content('13:00 ～ 22:00')&&have_content('12:00 ～ 23:00')\
                                      &&have_content('13:00 ～ 23:00')&&have_content('12:00 ～ 23:59')&&have_content('13:00 ～ 23:59')
        end
        it '11 のデータは返ってこない'do
          visit courts_path(court: {'open_time(4i)': '12', 'open_time(5i)': '00', 'close_time(4i)': '', 'close_time(5i)': '', court_types: [""]})
          expect(page).not_to have_content('11:00 ～')
        end
      end
      before do
        @court = FactoryBot.create(:court, open_time: nil, close_time: nil)
      end
      context '入力なし 存在データ null~null' do
        it '何も返ってこない' do
          visit courts_path(court: {'open_time(4i)': '', 'open_time(5i)': '', 'close_time(4i)': '', 'close_time(5i)': '', court_types: [""]})
          pending('nullのデータを対象とするか、後ほど修正するので保留（現状 null をはじくコードはない')
          expect(page).not_to have_content("#{@court.name}")
        end
      end
    end

    describe 'コートタイプ検索機能' do
      before do
        @court_types = Court.court_types.keys
        @courts = []
        Court.court_types.keys.each_with_index do |court_type,i|
          @courts[i] = FactoryBot.create(:court, court_type: court_type)
        end
      end
      context '入力コートタイプがkey[0],key[1]  データkey[0]~[4]のコートがあるなら' do
        it 'key[0],key[1]のコートが返ってくる' do
          visit courts_path(court: {court_types: [@court_types[0], @court_types[1]], 'open_time(4i)': '', 'open_time(5i)': '', 'close_time(4i)': '', 'close_time(5i)': ''})
          # byebug
          expect(page).to have_content(@courts[0].name)&&have_content(@courts[1].name)
        end
      end
      # 返ってこないver のテストも追加して
    end

    describe 'タグ検索機能' do
      before do
        @taggings = []
        5.times do |i|
          @taggings[i] = FactoryBot.create(:court_tag_tagging)
        end
      end
      context '入力tag 0,1,2 データ 0~4 （コートとタグと中間テーブルはそれぞれ５つある場合）' do
        it 'データ0,1,2 が返ってくる' do
          visit courts_path(Tag: {tag_ids: [Tag.first.id, Tag.second.id, Tag.third.id]}, court: {court_types: [""], 'open_time(4i)': '', 'open_time(5i)': '', 'close_time(4i)': '', 'close_time(5i)': ''})
          expect(page).to have_content(Court.where(id: CourtTagTagging.where(tag_id: Tag.first.id).first.court_id).first.name)\
                        &&have_content(Court.where(id: CourtTagTagging.where(tag_id: Tag.second.id).first.court_id).first.name)\
                        &&have_content(Court.where(id: CourtTagTagging.where(tag_id: Tag.third.id).first.court_id).first.name)
        end
        it 'データ3,4 は返ってこない'do
          visit courts_path(Tag: {tag_ids: [Tag.first.id, Tag.second.id, Tag.third.id]}, court: {court_types: [""], 'open_time(4i)': '', 'open_time(5i)': '', 'close_time(4i)': '', 'close_time(5i)': ''})
          # byebug
          expect(page).not_to have_content(Court.where(id: CourtTagTagging.where(tag_id: Tag.fourth.id).first.court_id).first.name)\
                        &&have_content(Court.where(id: CourtTagTagging.where(tag_id: Tag.fifth.id).first.court_id).first.name)\
        end
      end
    end
  end
end