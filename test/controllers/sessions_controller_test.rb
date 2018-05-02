require "test_helper"

describe SessionsController do

  describe "login" do
    it "should login a user and assign session user_id with valid input and redirect to root" do

      user = users(:dan)

      login(user)

      session[:user_id].must_equal user.id

      must_respond_with :redirect
      must_redirect_to :root
    end

    it "can login non-existing user by creating a new user with valid input and redirect to root" do
      delete logout_path

      new_user = {
        provider: "github",
        uid: 9998124,
        username: "test_user",
        email:  "test@user.com"
      }

      proc {
        user = User.new(new_user)
        login(user)
      }.must_change 'User.count', 1

      user = User.last
      session[:user_id].must_equal user.id

      must_respond_with :redirect
      must_redirect_to :root
    end

    it "cannot login non-existing user by creating a new user with invalid input and redirects to root" do
      delete logout_path

      new_user = {
        provider: "github",
        uid: nil,
        username: "test_user",
        email: "test@user.com"
      }

      proc {
        user = User.new(new_user)
        login(user)
      }.must_change 'User.count', 0

      session[:user_id].must_equal nil

      must_respond_with :redirect
      must_redirect_to :root
    end

    # Is this unecessary?
    it "can login another user while initial user is still logged on" do
      user1 = users(:dan)
      user2 = users(:kari)
      login(user1)
      login(user2)

      session[:user_id].must_equal user2.id

      must_respond_with :redirect
      must_redirect_to :root
    end
  end

  describe "logout" do
    it "can logout a logged in user" do
      user = users(:kari)
      login(user)

      session[:user_id].must_equal user.id

      delete logout_path
      must_respond_with :redirect
      must_redirect_to :root
    end

    it "can logout without a user logged in" do
      delete logout_path

      session[:user_id].must_equal nil

      must_respond_with :redirect
      must_redirect_to :root
    end
  end

end
