require 'test_helper'

describe UsersController do
  describe "index" do
    before do
      @user = User.first
      login(@user)
    end

    it "lists all users" do
      @user = User.first
      login(@user)
      get users_path
      must_respond_with :success
    end

  end

  describe "show" do
    before do
      OmniAuth.config.mock_auth[:github] = nil
    end

    it "displays a user with existant id" do
      user = User.first
      login(user)

      get user_path(user)
      must_respond_with :success
    end

    it "renders missing for a bogus id" do
      login(User.first)

      user_id = User.last.id + 1

      get user_path(user_id)
      must_respond_with :missing

    end
  end

  describe "auth_callback" do
    it "logs in an existing user and redirects to the root route" do

      start_count = User.count

      user = users(:dan)
      login(user)

      must_redirect_to root_path

      session[:user_id].must_equal user.id

      User.count.must_equal start_count
    end

    it "uses login method" do
      login(User.first)
      must_redirect_to root_path
    end

    it "creates an account for a new user and redirects to the root route" do
      old_user_count = User.count
      user = User.new(provider: "github", uid: 123123, email: "test@test.com", username: "Test User 1")
      login(user)
      must_redirect_to root_path

      new_user = User.find(session[:user_id])
      result = new_user.uid

      new_user_count = User.count

      result.must_equal user.uid
      new_user_count.must_equal old_user_count + 1
    end

    it "responds if given invalid user data" do
      OmniAuth.config.mock_auth[:github] = :invalid_credentials
      get auth_callback_path(:github)


      must_respond_with 302

    end
  end
end
