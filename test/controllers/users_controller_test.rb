require 'test_helper'

describe UsersController do
	describe "auth_callback" do
	 it "logs in an existing user and redirects to the root route" do
			start_count = User.count
			user = users(:dan)

			login(user)
			must_redirect_to root_path
			session[:user_id].must_equal user.id

			# Should *not* have created a new user
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
		  user = User.new(provider: "github", uid: 99999, username: "test_user", email: "test@user.com")

		  OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
		  get auth_callback_path(:github)

		  must_redirect_to root_path

		  User.count.must_equal start_count + 1

		  session[:user_id].must_equal User.last.id
	 end

	 it "redirects to the login route if given invalid user data" do
	 end
 end
	# it "should get index" do
  #   get users_path
	# 	must_respond_with :success
  # end

	# def show
	# 	@user = User.find_by(id: params[:id])
	# 	render_404 unless @user
	# end

end
