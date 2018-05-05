require "test_helper"

describe SessionsController do

  describe "login via auth_callback_path" do
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

      # call mock path in test helper
      login(new_user)
      # go to path and call login function in controller
      get auth_callback_path(:github)

      User.count.must_equal old_user_count + 1
      # must use User.last.id bc new_user is a local variable and doesn't have an id
      session[:user_id].must_equal User.last.id

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "logs in an existing user" do
      user = User.first
      old_user_count = User.count

      login(user)
      get auth_callback_path(:github)

      User.count.must_equal old_user_count
      session[:user_id].must_equal user.id

      must_respond_with :redirect
      must_redirect_to root_path
    end

    # first if statement doesn't get hit
    # for ex, auth hash doesn't include uid bc something is wrong w/ github
    it "doesn't login when user can't be found" do
      user = User.first
      user.uid = nil

      old_user_count = User.count

      login(user)
      get auth_callback_path(:github)

      must_respond_with :bad_request
      User.count.must_equal old_user_count
      session[:user_id].wont_equal user.id
    end

    it "can login even if another user is logged in as well" do
      kari = users(:kari)
      dan = users(:dan)

      # login as kari
      login(kari)
      get auth_callback_path(:github)
      session[:user_id].must_equal kari.id

      must_respond_with :redirect
      must_redirect_to root_path

      # login as dan
      login(dan)
      get auth_callback_path(:github)
      session[:user_id].must_equal dan.id

      must_respond_with :redirect
      must_redirect_to root_path
    end
  end

  describe "logout" do
    before do
      @kari = users(:kari)
    end

    it "logs out an authenticated user" do
      login(@kari)
      get auth_callback_path(:github)
      must_respond_with :redirect
      must_redirect_to root_path

      delete logout_path
      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "can login then logout then login again" do
      # login
      login(@kari)
      get auth_callback_path(:github)
      must_respond_with :redirect
      must_redirect_to root_path

      # logout
      delete logout_path
      must_respond_with :redirect
      must_redirect_to root_path

      # login again
      login(@kari)
      get auth_callback_path(:github)
      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "can login then logout then login as a different user" do
      # login kari
      login(@kari)
      get auth_callback_path(:github)
      must_respond_with :redirect
      must_redirect_to root_path

      # logout kari
      delete logout_path
      must_respond_with :redirect
      must_redirect_to root_path

      dan = users(:dan)
      # login dan
      login(dan)
      get auth_callback_path(:github)
      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "works even if no one's actually logged in" do
      delete logout_path
      must_respond_with :redirect
      must_redirect_to root_path
    end
  end

end
