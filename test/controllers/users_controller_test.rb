require 'test_helper'

describe UsersController do
	describe "index" do
		it "succeeds when there are users" do
			# Arrange - get users
			User.all.count.must_be :>, 0
			get users_path

			must_respond_with :success
		end

		it "succeeds when there are no users" do
			# Arrange
			User.destroy_all
			User.all.length.must_equal 0
			# Act
			get users_path
			# Assert
			must_respond_with :success
		end
	end

	describe "show" do
		it "finds a user if they exist" do
			# Arrange
			user = User.first
			# Arrange
      get user_path(user)
      # Assert
      must_respond_with :success
		end

		it "succeeds if a user doesn't exist" do
			# Arrange
			user = User.last.id + 1
			# Arrange
			get user_path(user)
			# Assert
			must_respond_with :not_found
 		end
	end
end
