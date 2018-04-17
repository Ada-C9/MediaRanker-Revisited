require "test_helper"

describe SessionsController do
  describe "login" do
    it "can login" do
      user = User.first

      post login_path, params: { username: user.username }
      must_respond_with :found

      user_id = session[:user_id]

      user_id.must_equal user.id
    end
  end

  describe "logout" do
    it "ends the session" do
      user = User.first
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))

      user_id = session[:user_id]

      user_id.must_equal user.id

      post logout_path, params: {user_id: user_id}
      user_id = session[:user_id]

      user_id.must_be_nil
    end
  end
end
