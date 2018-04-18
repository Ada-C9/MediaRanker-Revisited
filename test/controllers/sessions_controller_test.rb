require "test_helper"

#should have about 7 tests here

describe SessionsController do

  describe "login" do

    it "logs in an existing user and redirects to the root route" do
      existing_user = users(:grace)

      start_count = User.count

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(existing_user))
      # here ^ mock_auth is not a path or method thats being called - its part of the overall way OmniAuth is used..?

      get auth_callback_path(existing_user.provider)

      User.count.must_equal start_count
      must_redirect_to root_path
      session[:user_id].must_equal existing_user.id


      # # Notes below from class lecture notes:
      # # Count the users, to make sure we're not (for example) creating
      # # a new user every time we get a login request
      # start_count = User.count
      # # Get a user from the fixtures
      # user = users(:grace)
      # # Tell OmniAuth to use this user's info when it sees
      # # an auth callback from github
      # OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
      # # Send a login request for that user
      # # Note that we're using the named path for the callback, as defined
      # # in the `as:` clause in `config/routes.rb`
      # get auth_callback_path('github')
      # must_redirect_to root_path
      # # Since we can read the session, check that the user ID was set as expected
      # session[:user_id].must_equal user.id
      # # Should *not* have created a new user
      # User.count.must_equal start_count
    end

    it "must create a new user and redirects to the root route" do
      new_user = User.new(
        provider: 'github',
        uid: 666,
        username: 'new test user',
        email: 'test@test.com'
      )

      proc {
      perform_login(new_user) }.must_change 'User.count', 1

      must_redirect_to root_path
    end

    it "redirects to the root route and doesn't create new user if given invalid user data" do
      bad_user = User.new(
        provider: 'github',
        uid: 666,
        email: 'test@test.com'
      )

      proc {
      perform_login(bad_user) }.must_change 'User.count', 0

      must_redirect_to root_path
    end


  end

end
