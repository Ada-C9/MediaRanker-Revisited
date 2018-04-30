require "test_helper"

describe SessionsController do
  describe "login" do
    it "logs in an existing user and redirects to the root route" do
      users_before = User.count
      user = User.first
      login(user)

      must_respond_with :redirect
      must_redirect_to root_path

      session[:user_id].must_equal user.id
      User.count.must_equal users_before
    end

    it "creates an account for a new user and redirects to the root route" do
      users_before = User.count
      user = User.new(
        provider: "github",
        uid: 987654,
        username: "new user",
        email: "newuser@somethingcool.com"
      )
      login(user)

      must_respond_with :redirect
      must_redirect_to root_path

      session[:user_id].must_equal User.last.id
      User.count.must_equal users_before + 1
    end

    it "redirects to the root route and does not change DB if given invalid user data" do
      users_before = User.count
      user = User.new(
        provider: "google",
        uid: 12355,
        username: nil,
        email: nil
      )
      user.wont_be :valid?
      login(user)

      must_respond_with :redirect
      must_redirect_to root_path
      flash[:result_text].must_equal "Could not log in"
      session[:user_id].must_be_nil
      User.count.must_equal users_before
    end
  end

  describe "logout" do
    it "logouts a logged in user and redirects to root route" do
      user = User.first
      login(user)

      delete logout_path

      must_respond_with :redirect
      must_redirect_to root_path
      flash[:result_text] = "Successfully logged out"
      session[:user_id].must_be_nil
    end

    it "redirects to root route if no user is logged in" do
      delete logout_path
      session[:user_id].must_be_nil
      must_respond_with :redirect
      must_redirect_to root_path
    end
  end
end
