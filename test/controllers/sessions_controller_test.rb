require "test_helper"

describe SessionsController do

  describe "login" do
    it "should log in an existing user and redirect to the root path" do
      existing_user = users(:dan)

      proc {
        login(existing_user)
      }.must_change 'User.count', 0

      session[:user_id].must_equal existing_user.id
      flash[:status].must_equal :success
      must_respond_with :redirect
      must_redirect_to root_path
    end


    it "should redirect to the root path if given invalid user data" do
      invalid_user = User.new(
        provider: 'github',
      )

      proc {
        login(invalid_user)
      }.must_change 'User.count', 0

      session[:user_id].must_equal nil
      flash.now[:status].must_equal :failure
      must_respond_with :redirect
      must_redirect_to auth_callback_path
    end
  end

  describe "logout" do
    it "should log out user and redirect to the root path" do
      user_now = users(:dan)
      login(user_now)

    logout(user_now)

      session[:user_id].must_equal nil
      flash[:status].must_equal :success
      flash[:result_text].must_equal "Successfully logged out"
      must_respond_with :redirect
      must_redirect_to root_path
    end
  end
end
