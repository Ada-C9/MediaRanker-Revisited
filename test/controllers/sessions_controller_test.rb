require "test_helper"

describe SessionsController do
  describe "auth_callback" do
    it "logs in an existing user" do
      old_user_count = User.count
      user = users(:kari)

      login(user)

      User.count.must_equal old_user_count

      must_redirect_to root_path
      session[:user_id].must_equal user.id
      must_respond_with :redirect
    end

    it "creates a new user if one does not already exist" do
      old_user_count = User.count

      user = User.new(
        provider: "github",
        uid: 333333,
        username: "anne_test",
        email: "anne@anne.com"
      )

      login(user)

      must_redirect_to root_path

      User.count.must_equal old_user_count + 1
      session[:user_id].must_equal User.last.id
    end

    it "notifies user if there are errors" do
      user = User.new(
        provider: nil,
        uid: nil,
        username: nil,
        email: nil
      )
      login(user)

      flash.now[:result_text].must_equal "Could not log in"
    end
  end

  describe "logout" do
    it "successfully logs user out" do
      user = users(:kari)
      post logout_path(user)

      session[:user_id].must_equal nil
      must_respond_with :redirect
      must_redirect_to root_path
    end
  end
end
