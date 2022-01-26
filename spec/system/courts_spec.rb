require 'rails_helper'
require 'database_cleaner/active_record'

RSpec.describe 'Court', type: :system do
  describe "GET /index" do
    describe '地区検索機能' do
      before(:all) do
        DatabaseCleaner.strategy = :transaction
        DatabaseCleaner.start
        @factory_courts = FactoryBot.create_list(:court, 3)
      end
      after(:all) do
        DatabaseCleaner.clean
      end
      context 'area_id = [ 1, 2 ] 存在するデータのidが[ 1, 2, 3 ]なら' do
        it 'area_id = 1 or 2 のコートが返ってくる' do
          visit courts_path(Area: {area_ids: [ @factory_courts[0].area_id, @factory_courts[1].area_id ]})
          expect(page).to have_text(@factory_courts[0].name)&&have_text(@factory_courts[1].name)
        end
        it 'area_id = 3 のコートは返ってこない' do
          visit courts_path(Area: {area_ids: [ @factory_courts[0].area_id, @factory_courts[1].area_id ]})
          expect(page).not_to have_text(@factory_courts[2].name)
        end
      end
      context 'area_id = [] 存在するデータ[ 1, 2, 3 ]なら' do
        it '一致するコートがありません' do
          visit courts_path
          byebug
          expect(page).to have_text('一致するコートがありません')
        end
      end
    end
  end
end