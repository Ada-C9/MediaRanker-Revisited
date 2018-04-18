require "test_helper"

describe SessionsController do

  describe "login_form" do

    it "must succeed" do

      get login_path
      must_respond_with :success

    end

  end

  describe "login" do

    before do

      @unknown_user_name = "Yolanda"

    end

    it "must succeed for an existing user" do

      user_d = users(:dan)

      post login_path, params: {username: "dan"}

      session[:user_id].must_equal user_d.id

      must_redirect_to root_path


    end

    it "must succeed for a new user with a valid name" do

      existing_user = User.find_by(username: @unknown_user_name)

      existing_user.must_be_nil

      post login_path, params: {username: @unknown_user_name}

      session[:user_id].wont_be_nil
      must_redirect_to root_path

    end

    it "must create a new user instance when it recieves a new, valid username" do

      existing_user = User.find_by(username: @unknown_user_name)
      existing_user.must_be_nil
      before_user_count = User.all.count

      post login_path, params: {username: @unknown_user_name}

      after_user_count = User.all.count

      (after_user_count - before_user_count).must_equal 1
      new_user = User.find_by(username: @unknown_user_name)
      new_user.username.must_equal @unknown_user_name
      session[:user_id].must_equal new_user.id

    end

    it "must fail for a new user who doesn't enter a user name" do

      null_username = ""

      post login_path, params: {username: null_username}

      post login_path must_respond_with :bad_request

    end

  end

  describe "logout" do

    it "must succeed" do

      post login_path, params: {username: "testy test"}
      session[:user_id].wont_be_nil

      post logout_path

      session[:user_id].must_be_nil

    end
  end

end
