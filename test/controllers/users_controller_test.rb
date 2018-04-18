require 'test_helper'

describe UsersController do

  describe "index" do
    it "succeeds when there are users" do
      User.count.must_be :>, 0

      get users_path

      must_respond_with :success
    end

    it "succeeds when there are no users" do
      # skip
      User.destroy_all

      get users_path

      must_respond_with :success
    end
  end

  describe "show" do
    it "succeeds for an extant user ID" do
      user1 = User.first
      get user_path(user1)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus user ID" do
      user404 = User.last.id + 404
      get user_path(user404)
      must_respond_with :not_found
    end
  end

end
