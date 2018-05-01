require "test_helper"
require 'pry'

describe SessionsController do

  describe "create" do
    it "should log in the existing user and redirect to the root route" do
      before_count = User.count
      existing_user = users(:dan)

      proc {
        perform_login(existing_user)
      }.must_change 'User.count', 0
      must_redirect_to root_path
      must_respond_with :redirect

      User.count.must_equal before_count
    end

    it "should create a new user and redirect to the root route" do
      new_user = User.new(
        provider: 'github',
        uid: 777,
        name: 'test user',
        email: 'test@test.com',
      )

      proc {
        perform_login(new_user)
      }.must_change 'User.count', 1

      must_redirect_to root_path
      must_respond_with :redirect
    end
  end

end
