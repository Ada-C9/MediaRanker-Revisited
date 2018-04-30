require "test_helper"

describe SessionsController do
  describe 'auth_callback' do

    it 'logs in an existing user' do
      #arrange
      user = User.first
      old_user_count = User.count

      login(user)
      User.count.must_equal old_user_count
      session[:user_id].must_equal user.id
    end

    it 'does not log in with insufficient data' do
      user = User.new(
        provider: 'github',
        email: 'test@tester.com',
      )
      user.wont_be :valid?
      old_user_count = User.count

      login(user)
      User.count.must_equal old_user_count
    end

    it 'does not log in if the user data is invalid' do
      user = User.first
      dup_user = User.new(
        provider: 'github',
        uid: 80085,
        email: 'test@tester.com',
        name: user.name
      )
    end

    #what about if the user is already logged in?
  end
end
