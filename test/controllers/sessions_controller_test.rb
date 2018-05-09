require "test_helper"
require 'pry'

describe SessionsController do
  describe "login" do
    it "logs in an existing user and redirects to the root route" do

      start_count = User.count
      user = users(:grace)
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
      get login_path(:github)

      must_redirect_to root_path
      session[:user_id].must_equal user.id
      User.count.must_equal start_count
    end

    it "creates an account for a new user and redirects to the root route" do
      start_count = User.count
      user = User.new(provider: "github", uid: 98765, username: "tim")
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
      get login_path(:github)

      user = User.find_by(uid: 98765)

      must_redirect_to root_path
      session[:user_id].must_equal user.id
      User.count.must_equal start_count + 1
    end

    it "redirects to the login route if given invalid user data" do
      start_count = User.count

      user = User.new(provider: "github", uid: 98765, username: nil)
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
      get login_path(:github)

      must_redirect_to root_path
      User.count.must_equal start_count
    end

    it "redirects if there is no auth hash uid" do
      user = User.new(provider: "github", uid: 98765, username: nil)
      test_hash = mock_auth_hash(user)
      test_hash[:uid] = nil


      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(test_hash)

      get login_path(:github)

      must_redirect_to root_path
      flash[:error].must_equal "Could not log in"
    end
  end

  describe "logout" do
    it "ends session" do
      user = users(:ada)
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
      get login_path(:github)

      delete logout_path

      must_redirect_to root_path
      session[:user_id].must_equal nil
      flash[:success].must_equal "Successfully logged out!"
    end
  end
end
