require "test_helper"

describe SessionsController do

  describe "login" do

    it "logs in returning user" do
      user = User.first.username

      user_count = User.count

      get login_path, params: {username: user}

      must_respond_with :success

      User.count.must_equal user_count

    end

    # it "creates a new session with valid data" do
    #
    #   # would this even be a separate test from login?
    #
    # end

    it "does not create a new session with invalid data" do

      username = ""

      get login_path, params: {username: username}

      user_count = User.count

      must_respond_with :bad_request

      User.count.must_equal user_count

      session[:user_id].must_equal nil

    end
  end


  describe "destroy" do

    it "destroys session on logout" do

      user = User.first

      username = user.username

      get login_path, params: {username: username}

      post logout_path

      session[:user_id].must_equal nil

    end
  end


  # user = User.first
  # old_user_count = User.count
  #
  # # login(user)
  #
  # User.count.must_equal old_user_count
  # session[:user_id].must_equal user.id
  #
  #
  # new_user = User.new(username: "thinking", provider: "github", uid: 90808, email: "test@testy.org", name: 'Alum Mcallster' )
  #
  # new_user.save



end
