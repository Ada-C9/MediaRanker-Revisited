require "test_helper"

describe SessionsController do
  describe "login" do
    it "can login" do
      user = User.first
      login(user)

      user_id = session[:user_id]

      user_id.must_equal user.id
    end
  end

  describe "logout" do
    it "ends the session" do
      user = User.first
      login(user)

      user_id = session[:user_id]

      user_id.must_equal user.id

      post logout_path, params: {user_id: user_id}
      user_id = session[:user_id]

      user_id.must_be_nil
    end
  end
end
