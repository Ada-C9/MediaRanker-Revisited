require "test_helper"
require 'pry'

describe SessionsController do
  before do
    @user = User.new(username: 'thebatman', uid: 1, email: "iamthebatman@example.com", provider: "github")
    @user.must_be :valid?
    @user.save
  end

  describe 'login' do

    it 'logs in an existing user' do
      old_user_count = User.count

      login(@user)

      must_respond_with :redirect
      must_redirect_to root_path
      session[:user_id].must_equal @user.id
      User.count.must_equal old_user_count
    end

    it 'responds with success for a new user' do
      User.delete_all
      User.count.must_equal 0

      login(@user)

      must_respond_with :redirect
      must_redirect_to root_path
      session[:user_id].must_equal User.last.id
      User.count.must_equal 1
    end

    it 'responds with bad_request for a new user with an empty username' do
      User.delete_all
      User.count.must_equal 0
      user = User.new(uid: 2, email: "iamthebatman@example.com", provider: "github")
      user.wont_be :valid?

      login(user)

      # must_respond_with :bad_request
      session[:user_id].must_be_nil
      User.count.must_equal 0
    end

  end # login

  describe 'logout' do

    it 'responds with success' do
      login(@user)
      session[:user_id].must_equal @user.id
      post logout_path
      must_respond_with :redirect
      must_redirect_to root_path
      session[:user_id].must_be_nil
    end
  end # logout

end # SessionsController
