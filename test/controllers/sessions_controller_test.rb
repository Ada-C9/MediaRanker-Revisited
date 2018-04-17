require "test_helper"

describe SessionsController do
  describe "login_form" do
    it "succeeds" do
      get login_path
      must_respond_with :success
    end
  end

  describe "login" do
    it "succeeds with an existing username and redirects to root_path" do
      post login_path, params: {
        username: users(:dan)
      }

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "succeeds with new valid username and redirects to root path" do
      post login_path, params: {
        username: "mary"
      }

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "renders bad_request with invalid username" do
      post login_path, params: {
        username: ""
      }

      must_respond_with :bad_request
    end
  end

  describe "logout" do
    it "changes session user id to nil" do
      skip
      post login_path, params: {
        username: users(:dan)
      }
      session[:user_id].must_equal users(:dan).id
      post logout_path
      session[:user_id].must_equal nil
    end

    it "must redirect to root path" do
      post login_path, params: {
        username: users(:dan)
      }
      post logout_path

      must_respond_with :redirect
      must_redirect_to root_path
    end
  end

end
