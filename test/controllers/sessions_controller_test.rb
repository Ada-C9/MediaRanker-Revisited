require "test_helper"

describe SessionsController do
  describe "auth_callback" do
    it "creates a DB entry for a new user" do
      user = User.new(
        provider: "github",
        uid: 9999,
        email: "test@test.org",
        username: "test user"
      )
      user.must_be :valid?
      old_user_count = User.count
      login(user)
      User.count.must_equal old_user_count + 1
      session[:user_id].must_equal User.last.id
    end

    it "logs in an existing user" do
      user = User.first
      old_user_count = User.count
      login(user)

      User.count.must_equal old_user_count
      session[:user_id].must_equal user.id
    end


  end
end
