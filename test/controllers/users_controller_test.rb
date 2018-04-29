require 'test_helper'

describe UsersController do
  describe "index" do
    it "succeeds when there are users" do
      User.count.must_be :>, 0

      get users_path
      must_respond_with :success
    end

    it "succeeds when there are no users" do
      Vote.destroy_all
      User.destroy_all
      Vote.count.must_equal 0
      User.count.must_equal 0

      get users_path
      must_respond_with :success
    end
  end

  describe "show" do
    it "succeeds for an existing user ID" do
      user_id = User.first.id

      get user_path(user_id)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus user ID" do
      user_id = User.last.id + 1

      get user_path(user_id)
      must_respond_with :not_found
    end
  end
end
