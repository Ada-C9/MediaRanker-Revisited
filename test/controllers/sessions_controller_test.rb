require "test_helper"

describe SessionsController do
  describe "create" do
    it "should log in an existing user and redirect to the root route" do
      before_count = User.count
      existing_user = users(:ada)

      perform_login(existing_user)

      must_redirect_to root_path
      User.count.must_equal before_count
    end

    it "should create a new user and redirect to the root route" do
      new_user = User.new(
        provider: "github",
        uid: 239802,
        name: "test user",
        email: "test@test.com"
      )

      proc {
        perform_login(new_user)
      }.must_change "User.count", 1

      must_respond_with :redirect
      must_redirect_to root_path
    end
  end

end
