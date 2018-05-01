require 'test_helper'

describe UsersController do
	describe "auth_callback" do # aka login
	 it "logs in an existing user and redirects to the root route" do
			start_count = User.count
			user = users(:dan)

			login_for_test(user)
			must_redirect_to root_path
			session[:user_id].must_equal user.id

			User.count.must_equal start_count

		 ## longer way before shortcut
		 # start_count = User.count
		 # user = users(:dan)
		 #
		 # OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
		 # get auth_callback_path(:github)
		 #
		 # must_redirect_to root_path
		 # session[:user_id].must_equal user.id
		 # User.count.must_equal start_count
	 end

	 it "creates an account for a new user and redirects to the root route" do
		 	start_count = User.count
		  user = User.new(provider: "github", uid: 99999, username: "test_user",
				email: "test@user.com")

		  OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
		  get auth_callback_path(:github)

		  must_redirect_to root_path

		  User.count.must_equal start_count + 1

		  session[:user_id].must_equal User.last.id
	 end

	 it "redirects to the login route if given invalid user data" do
		 start_count = User.count
		 user = User.new(provider: "github", uid: 99999, username: nil,
			 email: "test@user.com") # username is nil

		 OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
		 get auth_callback_path(:github)

		 must_redirect_to root_path

		 User.count.must_equal start_count

		 session[:user_id].must_be_nil
	 end
 end

	describe "auth_callback" do # aka login
	  it "logs in an existing user and redirects to the root route" do
	 		start_count = User.count
	 		user = users(:dan)

	 		login_for_test(user)
	 		must_redirect_to root_path
	 		session[:user_id].must_equal user.id

	 		User.count.must_equal start_count

	  end
	end
end
