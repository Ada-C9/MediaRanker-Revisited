require "test_helper"

describe SessionsController do
  describe 'auth_callback' do
    it 'signs in an existing user' do
      user = User.first
      old_user_count = User.count

      login(user)

      must_redirect_to root_path
      User.count.must_equal old_user_count
      session[:user_id].must_equal user.id
    end

    it 'creates a new DB entry for a new user' do
      user_data = {
        name: 'A Name',
        email: 'name@anemail.com',
        uid: 99999,
        provider: 'github'
      }
      user = User.new(user_data)
      user.valid?.must_equal true

      old_user_count = User.count


      login(user)

      must_redirect_to root_path
      User.count.must_equal old_user_count + 1
      session[:user_id] = User.last.id
    end

    it 'will not login a user if not enough information is returned from provider' do
      user_data = {
        name: 'A Name',
        email: 'name@anemail.com',
        provider: 'github'
      }
      user = User.new(user_data)
      user.valid?.must_equal false

      old_user_count = User.count


      login(user)

      must_redirect_to root_path
      User.count.must_equal old_user_count
      session[:user_id].must_be_nil
    end

    it 'will sign in a user that is already signed in' do
      user = User.first
      old_user_count = User.count

      login(user)
      session[:user_id].must_equal user.id

      login(user)

      must_redirect_to root_path
      User.count.must_equal old_user_count
      session[:user_id].must_equal user.id
    end
  end

  describe 'logout' do
    it 'logs out a logged in user' do
      user = User.first

      login(user)
      session[:user_id].must_equal user.id

      post logout_path

      session[:user_id].must_be_nil
    end
  end
end
