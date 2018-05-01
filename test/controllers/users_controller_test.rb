require 'test_helper'

describe UsersController do
  describe 'index' do
    it "should get index" do
      User.count.must_be :>, 0
      get users_path
      must_respond_with :success
    end

    it "should get delete" do
      Vote.destroy_all
      User.destroy_all
      get users_path
      must_respond_with :success
    end

  end

  describe 'show' do
    it "should respond to show" do
      get user_path(User.first)
      must_respond_with :success
    end

    it "should not show non-existant user " do
      get user_path(100)
      must_respond_with :not_found
    end

  end
end

#
# require 'test_helper'
#
# describe UsersController do
#   describe "index" do
#     it "succeeds with many users" do
#       # Assumption: there are many users in the DB
#       User.count.must_be :>, 0
#
#       get users_path
#       must_respond_with :success
#     end
#
#     it "succeeds with no users" do
#       # Start with a clean slate
#       Vote.destroy_all # for fk constraint
#       User.destroy_all
#
#       get users_path
#       must_respond_with :success
#     end
#   end
#
#   describe "show" do
#     it "succeeds for an extant user" do
#       get user_path(User.first)
#       must_respond_with :success
#     end
#
#     it "renders 404 not_found for a bogus user" do
#       # User.last gives the user with the highest ID
#       bogus_user_id = User.last.id + 1
#       get user_path(bogus_user_id)
#       must_respond_with :not_found
#     end
#   end
# end
