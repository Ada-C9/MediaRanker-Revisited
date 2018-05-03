require 'test_helper'

describe UsersController do

  describe 'index' do

    it "sends a success response when there are many users" do
      User.count.must_be :>, 0

      get users_path

      must_respond_with :success
    end

    it "sends a success response when there are no users" do
      User.destroy_all

      get users_path

      must_respond_with :success
    end

  end

  describe 'show' do

    it "sends a success response when the user exists" do

      get user_path(User.first)

      must_respond_with :success

    end

    it "responds with not_found if the user doesn't exist" do

      user = User.last.id + 1

      get user_path(user)

      must_respond_with :not_found

    end

  end

  describe "auth_callback" do

    it "logs in an existing user and redirects to root_path" do
      start_count = User.count
      user = users(:dan)

      login(user)

      must_redirect_to root_path
      session[:user_id].must_equal user.id
      User.count.must_equal start_count
    end

    it "creates a new user" do
      start_count = User.count
      user = User.new(provider: "github", uid: 12345)

      login(user)

      must_redirect_to root_path

      User.count.must_equal start_count + 1
      session[:user_id].must_equal User.last.id
    end

  end

end
