require "test_helper"

describe SessionsController do

  describe "login_form" do

    it "must succeed" do

      get login_path
      must_respond_with :success

    end

  end

  describe "login" do

    @unknown_user_name = "Yolanda"

    it "must succeed for an existing user" do

      user_d = users(:dan)
      post login_path, params: {username: "dan"}

      session[:user_id].must_equal user_d.id
      must_redirect_to root_path
      must_respond_with :success

    end

    it "must succeed for a new user with a valid name" do

      # user_y = User.new {params: {username: "Yolanda"}}
      #
      # user_y.id.wont_be_nil
      existing_user = User.find_by(username: @unknown_user_name)

      existing_user.must_be_nil

      post login_path, params: {username: @unknown_user_name}

      post login_path must_respond_with :success
      must_redirect_to root_path

    end

    it "must create a new user when it recieves a new, valid username" do

      existing_user = User.find_by(username: @unknown_user_name)

      existing_user.must_be_nil

      post login_path, params: {username: @unknown_user_name}

      new_user = User.find_by(username: @unknown_user_name)
      new_user.wont_be_nil

      session[:user_id].must_equal new_user.id

    end

    it "must fail for a new user who doesn't enter a user name" do

      null_username = ""

      post login_path, params: {username: null_username}

      post login_path must_respond_with :bad_request
      must_redirect_to root_path

    end

  end

  describe "logout" do

    it "must succeed" do

      post logout_path

      must_respond_with :success

    end
  end

end
