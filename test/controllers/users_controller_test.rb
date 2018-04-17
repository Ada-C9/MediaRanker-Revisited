require 'test_helper'

describe UsersController do
  # describe "index" do
  #   before do
  #     @user = User.first
  #     login(@user)
  #   end
  #
  #   it "lists all users" do
  #     @user = User.first
  #     login(@user)
  #     get users_path
  #     must_respond_with :success
  #   end
  #
  # end

  describe "show" do
    before do
      user = User.first
      login(user)
    end

    it "displays a user with existant id" do
      user = User.first
      # login(user)

      get user_path(user)
      must_respond_with :success
    end

    it "renders missing for a bogus id" do
      # login(User.first)

      user_id = User.last.id + 1

      get user_path(user_id)
      must_respond_with :missing

    end
  end

  describe "auth_callback" do
    it "logs in an existing user and redirects to the root route" do

      start_count = User.count

      user = users(:dan)

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
      get auth_callback_path(:github)

      must_redirect_to root_path

      session[:user_id].must_equal user.id

      User.count.must_equal start_count
    end

    it "uses login method" do
      login(User.first)
      must_redirect_to root_path
    end

    it "creates an account for a new user and redirects to the root route" do
    end

    it "redirects to the login route if given invalid user data" do
    end
  end
end
