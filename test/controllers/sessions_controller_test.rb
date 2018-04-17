require "test_helper"

describe SessionsController do
  describe "login_form" do
    it "succeeds in rendering the login form" do
      get login_path
      must_respond_with :success
    end
  end

  describe "login" do
    it "responds with found for with a valid new or returning user name" do
      post login_path, params: { username: "new user"}
      must_respond_with :found
      must_redirect_to root_path
    end

    it "does not add new user to db if the user is exists already" do
      proc {
        post login_path, params: { username: "kari"}
      }.must_change 'User.count', 0
      must_respond_with :found
    end

    it "adds new user to the db" do
      proc {
        post login_path, params: { username: "new user"}
      }.must_change 'User.count', 1
      must_respond_with :found
    end

    it "repsonds with bad_request when no user name is given" do
      post login_path, params: { username: nil }
      must_respond_with :bad_request
    end
  end

  describe "logout" do
    it "suceeds in logging out user" do
      post login_path, params: { username: "new user"}
      post logout_path
      must_respond_with :found
      must_redirect_to root_path
    end
  end
end
