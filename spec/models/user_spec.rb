require 'rails_helper'

RSpec.describe User, type: :model do
  it "メアド・パスワード・退会ステータスがあるならok" do
    user = User.new(
      email: "hogehoge@example.com",
      password: "aiaiai19",
      )
      expect(user).to be_valid
  end

  it "メアドがない場合無効" do

  end
  it "パスワードがない場合ng"
  it "メアド重複は無効"
  it "退会ステータスがデフォルトfalseは無効"

end
