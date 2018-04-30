require "test_helper"

describe SessionsController do
  describe 'auth_callback' do
    it 'signs in an existing user' do
      user = User.first
      old_user_count = User.count

      login(user)

      get auth_callback_path(:github)

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


  end
end
