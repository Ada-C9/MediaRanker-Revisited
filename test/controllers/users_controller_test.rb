require 'test_helper'

describe UsersController do
	# LOGGED IN ------------------------------------------------------------------
	describe "Logged in users" do
		describe "index" do
			before do
				login_for_test(users(:kari))
			end

			it "succeeds for logged in user" do
				get users_path
				must_respond_with :success
			end

		end

		describe "show" do
			before do
				login_for_test(users(:kari))
			end

			it "succeeds for a user that exists" do
				user_id = users(:dan).id
				get user_path(user_id)
				must_respond_with :success
			end

			it "returns 404 not_found for a work that D.N.E." do
				non_user_id = User.last.id + 1
				get user_path(non_user_id)
				must_respond_with :not_found
			end
		end
	end

	# NOT LOGGED IN --------------------------------------------------------------
	describe "Note Logged in users" do
		describe "index" do

			it "succeeds for logged in user" do
				get users_path
				must_respond_with :not_found
			end

		end

		describe "show" do

			it "succeeds for a user that exists" do
				user_id = users(:dan).id
				get user_path(user_id)
				must_respond_with :not_found
			end

			it "returns 404 not_found for a work that D.N.E." do
				non_user_id = User.last.id + 1
				get user_path(non_user_id)
				must_respond_with :not_found
			end
		end
	end
end
