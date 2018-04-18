require "test_helper"

describe SessionsController do
  describe 'login' do
    # USER EXSISTS ALREADY
    it 'logs in an exsisting user' do
      user = users(:dan)

      post login_path, params: {username: user.username}

      # Now we should have access to a session. And can test that we are in it.
      session.keys.must_include "user_id"
      session["user_id"].must_equal user.id

      # Flash needs to be tested Now
      flash.keys.must_include "status"
      flash["status"].must_equal :success
      flash.keys.must_include 'result_text'

      must_redirect_to root_path
    end

    # USER DOES NOT EXSIST, WE CREATE NEW USER
    it 'logs in a new User' do
      username = 'test username'

      counting = User.count

      User.new(username: username).must_be :valid?

      post login_path, params: {username: username}

      # Now we should have access to a session. And can test that we are in it.
      session.keys.must_include "user_id"
      session["user_id"].must_equal User.last.id

      # Flash needs to be tested Now
      flash.keys.must_include "status"
      flash["status"].must_equal :success
      flash.keys.must_include 'result_text'

      User.count.must_equal counting + 1
      must_redirect_to root_path
    end

    # USER DOESN'T EXSIST AND CANNOT CREATE
    it 'renders bad request for an invalid username' do
      username = nil

      counting = User.count

      User.new(username: username).wont_be :valid?

      post login_path, params: {username: username}

      session.keys.wont_include "user_id"

      flash.keys.must_include "status"
      flash["status"].must_equal :failure
      flash.keys.must_include 'messages'
      flash.keys.must_include 'result_text'

      User.count.must_equal counting
      must_respond_with :bad_request
    end
  end

  # TODO: WRITE TESTS FOR LOGOUT
  describe 'logout' do

  end
end
