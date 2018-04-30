require "test_helper"

describe SessionsController do
	describe "create" do
		it "succeeds and redirects user upon logging in" do
			# Arrange
			user = User.first

			OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))

      get auth_callback_path(:github)

			# Act
			proc {
				post login_path
			}

			# Assert
      must_redirect_to root_path
      session[:user_id].must_equal user.id
		end

		# it "redirects user if log in fails" do
		# 	# Arrange
		# 	user = User.first
		#
		# 	OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
		#
		# 	OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
		#
		# 	get auth_callback_path(:github)
		#
		# 	# Assert
		# 	must_redirect_to root_path
		# 	flash[:status].must_equal :failure
		# end
	end

	describe "logout" do
		describe "redirects user upon logging out" do
			it "logs user out if they exist" do
				# Arrange
				user = User.first

				OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))

				get auth_callback_path(:github)

				# Act
				proc {
					post logout_path
				}

				# Assert
				must_redirect_to root_path
				# session[:user_id].must_equal nil
			end
		end
	end

end
