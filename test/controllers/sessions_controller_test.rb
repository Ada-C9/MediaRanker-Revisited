require "test_helper"

describe SessionsController do
  describe "auth_callback" do
    it "logs in an existing user" do
      user = User.first
      login(user)

      must_respond_with :redirect
      must_redirect_to root_path
      session[:user_id].must_equal user.id
    end

    it "creates a new user if one does not already exist" do

    end
  end
end
