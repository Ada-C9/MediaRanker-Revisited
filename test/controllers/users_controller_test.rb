require 'test_helper'

describe UsersController do
  describe "index" do
    it "succeeds with many users" do
      User.count.must_be :>, 0

      get users_path
      must_respond_with :success
    end

    it "succeeds with no users" do
      Vote.destroy_all
      User.destroy_all

      get users_path
      must_respond_with :success
    end
  end

  describe "show" do
    it "succeeds for an extant user" do
      get user_path(User.first)
      must_respond_with :success
      get user_path(User.last)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus user" do
      user_id = User.last.id + 1
      get user_path(user_id)
      must_respond_with 404
    end
  end
end
