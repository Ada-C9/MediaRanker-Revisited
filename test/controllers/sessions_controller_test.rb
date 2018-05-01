require "test_helper"

describe SessionsController do

  describe "login_form" do
    it "succeeds" do
      get login_path
      must_respond_with :success
    end
  end

  describe "login" do
    it "should login a user and assign session user_id with valid input and redirect to root" do

      user = users(:dan)

      post login_path, params: {
          username: user.username,
          uid: user.uid,
          provider: user.provider,
          email: user.email
        }

      session[:user_id].must_equal user.id

      must_respond_with :redirect
      must_redirect_to :root
    end

    it "can login non-existing user by creating a new user with valid input and redirect to root" do
      proc {
        post login_path, params: {
          username: "new_user",
          uid: 9999,
          provider: "github",
          email: "new@gmail.com"
        }
      }.must_change 'User.count', 1

      user = User.last
      session[:user_id].must_equal user.id

      must_respond_with :redirect
      must_redirect_to :root
    end

    it "cannot login non-existing user by creating a new user with invalid input and render bad_request" do
      proc {
        post login_path, params: {
          username: nil,
          uid: 9999,
          provider: "github",
          email: "new@gmail.com"
        }
      }.must_change 'User.count', 0

      must_respond_with :bad_request
    end

    # Is this unecessary?
    it "can login another user while initial user is still logged on" do
      user1 = users(:dan)
      user2 = users(:kari)
      post login_path, params: {
        username: user1.username,
        uid: user1.uid,
        provider: user1.provider,
        email: user1.email
      }

      post login_path, params: {
        username: user2.username,
        uid: user2.uid,
        provider: user2.provider,
        email: user2.email
      }

      session[:user_id].must_equal user2.id

      must_respond_with :redirect
      must_redirect_to :root
    end
  end

  describe "logout" do
    it "can logout a logged in user" do
      user = users(:kari)
      post login_path, params: {
        username: user.username,
        uid: user.uid,
        provider: user.provider,
        email: user.email
      }

      session[:user_id].must_equal user.id

      must_respond_with :redirect
      must_redirect_to :root
    end

    it "can logout without a user logged in" do
      post logout_path

      session[:user_id].must_equal nil

      must_respond_with :redirect
      must_redirect_to :root
    end
  end

end
