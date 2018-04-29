require "test_helper"

describe SessionsController do

  describe "login" do
    it "should log in an existing user and redirect to the root route" do
      existing_user = users(:ada)

      proc {
        perform_login(existing_user)
      }.must_change 'User.count', 0

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "should create a new user and redirect to the root route given valid user data" do
      new_user = User.new(
        provider: 'github',
        uid: 999,
        email: 'test@test.com',
        username: 'test user'
      )

      proc {
        perform_login(new_user)
      }.must_change 'User.count', 1

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "should respond with error given bogus user data" do
      bad_user = User.new(
        provider: 'foo',
      )

      proc {
        perform_login(bad_user)
      }.must_change 'User.count', 0

      must_respond_with :error
    end
  end

  describe "logout" do
    it "should log out user and redirect to the root route" do
      current_user = users(:ada)

      perform_logout(current_user)

      must_respond_with :redirect
      # DEBUG
      # must_redirect_to root_path
    end
  end
end
