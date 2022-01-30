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
end
