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

      post login_path, params: { username: user.username }

      session[:user_id].must_equal user.id

      must_respond_with :redirect
      must_redirect_to :root
    end
  end

end
