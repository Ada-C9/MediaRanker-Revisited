require "test_helper"

describe SessionsController do

  describe "auth_callback" do
    it "logs in an existing user and redirect to root route" do
      user = User.first
      old_user_count = User.count

      login(user)

      must_redirect_to root_path
      User.count.must_equal old_user_count
      session[:user_id].must_equal user.id
    end

    it "creates a DB entry for a new user and redirect to root path" do
      user = User.new(
        provider: "github",
        uid: 505,
        email: "dada@test.org",
        username: "dadatest"
      )

      user.must_be :valid?
      old_user_count = User.count

      login(user)

      User.count.must_equal old_user_count + 1
      must_redirect_to root_path
      session[:user_id].must_equal User.last.id
    end

    it "does not log in with insufficient data and redirect to root path" do
      user = User.new(
        provider: "github",
        email: "dada@test.org",
        username: "coco"
      )

      old_user_count = User.count

      login(user)
      flash[:error].must_equal "Could not log in"
      User.count.must_equal old_user_count
      must_redirect_to root_path
    end

  end

  describe "logout" do
    it "logs out a login user" do
      user = User.first
      login(user)

      delete logout_path

      session[:user_id].must_equal nil
    end


    it "can only logout the login user account" do
      user = User.first

      delete logout_path

      must_redirect_to root_path
      flash[:status].must_equal :failure
    end
  end
end
