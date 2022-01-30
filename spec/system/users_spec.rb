require 'rails_helper'


RSpec.describe 'User', type: :system do
  describe 'ユーザー登録' do
    it 'ユーザー登録すると登録される' do
      visit new_user_registration_path
      find('#user_name').set('太郎')
      find('#user_email').set('hogehogehoge@example.com')
      find('#user_password').set('aiueoaiueo')
      find('#user_password_confirmation').set('aiueoaiueo')
      click_button('ユーザー登録')
      expect(User.last.email).to eq'hogehogehoge@example.com'
    end
  end
  describe 'ユーザー情報編集' do
    before do
      @user = FactoryBot.create(:user)
    end
    it 'ユーザー情報を変更する' do
      login_as(@user)
      visit edit_user_path(@user.id)
      find('#user_email').set('aaaa@example.com')
      click_button('編集内容を保存')
      expect(User.find(@user.id).email).to eq('aaaa@example.com')
    end
  end
end
