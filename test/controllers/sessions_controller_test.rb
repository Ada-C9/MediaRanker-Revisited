require "test_helper"

describe SessionsController do

  describe 'auth_callback' do
    it 'creates a db entry for a new user' do
      new_user = User.new (
        {
          provider: 'github',
          uid: '123',
          email: 'alex@adaacademy.org',
          username: 'alex'
        }
      )
      new_user.must_be :valid?
      old_user_count = User.count


      ########### HERE ##########
      # in test helper, not controller
      login(new_user)
      # goes to path, goes to login in controller
      get auth_callback_path(:github)

      User.count.must_equal old_user_count + 1
      # must use User.last.id bc new_user is a local variable and doesn't have an id
      session[:user_id].must_equal User.last.id

      # Did it redirect?
    end

    it 'logs in an existing user' do
      user = User.first
      old_user_count = User.count

      login(user)
      get auth_callback_path(:github)

      User.count.must_equal old_user_count
      session[:user_id].must_equal user.id
    end

    # first if statement doesn't get hit
    # for ex, auth hash doesn't include uid bc something is wrong w/ github
    it 'does not login when user cant be found' do
      user = User.first
      user.uid = nil

      old_user_count = User.count

      login(user)
      get auth_callback_path(:github)

      must_respond_with :bad_request
      User.count.must_equal old_user_count
      session[:user_id].wont_equal user.id
    end

    # ADD TESTS FOR logout
    # try to logout but no one logged in
    # logged out then login`

  end

end
