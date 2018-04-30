require 'test_helper'

describe UsersController do

  describe "index" do
    it "succeeds when there are users" do
      get users_path

      must_respond_with :success
    end

    it "succeeds when there are no users" do
      User.destroy_all

      get users_path

      must_respond_with :success
    end
  end

  describe "show" do
    it "succeeds for an extant user ID" do
      get user_path(users(:ada).id)

      must_respond_with :success
    end

    it "renders 404 not_found for invalid user ID" do
      get user_path(" ")

      must_respond_with :not_found
    end
  end
end
