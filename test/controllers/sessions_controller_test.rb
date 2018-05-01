require "test_helper"

describe SessionsController do

  # write at least 8 tests... depending on how oauth is implemented
  describe 'login' do
    it 'should log in an existing user and redirects to the root route' do
      before_count = User.count
      existing_user = users(:ada)

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(existing_user))

      get auth_callback_path(existing_user.provider)

      User.count.must_equal before_count
      must_redirect_to root_path
      session[:user_id].must_equal existing_user.id
    end

    it "creates an account for a new user and redirects to the root route" do
      new_user = User.new(
        provider: 'github',
        uid: 999,
        username: 'test user',
        email: 'test@test.com'
      )

      proc {
      perform_login(new_user) }.must_change 'User.count', 1

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "fails if a user is already logged in and a user attempts to log in" do
      existing_user = users(:grace)
      perform_login(existing_user)

      proc {
      perform_login(existing_user) }.wont_change 'User.count'

      must_redirect_to root_path
    end

    it "redirects to the root route and doesn't create new user if given invalid user data" do
      bad_user = User.new(
        provider: 'github',
        uid: 666,
        email: 'test@test.com'
      )

      proc {
      perform_login(bad_user) }.wont_change 'User.count'

      must_redirect_to root_path
    end
  end

  describe "logout" do

    it "can log out a logged in user" do
      perform_login(users(:ada))
      delete logout_path

      session[:user_id].must_be_nil
      must_redirect_to root_path
    end
  end
end
