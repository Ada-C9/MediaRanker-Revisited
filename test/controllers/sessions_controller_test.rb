require "test_helper"

describe SessionsController do

  # write at least 8 tests... depending on how oauth is implemented
  describe 'login' do
    it 'should log in an existing user and redirects to the root route' do
      before_count = User.count
      existing_user = users(:ada)

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))

      get auth_callback_path(existing_user.provider)

      User.count.must_equal before_count
      must_redirect_to root_path
      session[:user_id].must_equal user.id
    end

    it "creates an account for a new user and redirects to the root route" do
      new_user = User.new(
      provider: 'github',
      uid: 999,
      name: 'test user',
      email: 'test@test.com'
      )

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))

      proc {
        get auth_callback_path(new_user.provider)
      }.must_change, 'User.count', 1

      must_respond_with :reidrect
      must_redirect_to root_path

    end

    it "redirects to the login route if given invalid user data" do
    end
  end

end
