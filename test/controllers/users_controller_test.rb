require 'test_helper'

describe UsersController do
  describe "index" do
    it "succeeds with at least 1 user" do
      User.all.nil?.must_equal false
      get users_path
      must_respond_with :success
    end

    it "succeeds with no users" do
      Vote.destroy_all
      User.destroy_all
      User.count.must_equal 0
      get users_path
      must_respond_with :success
    end
  end

  describe "show" do
    it "succeeds with existing user" do
      user = users(:kari)
      get user_path(user.id)
      must_respond_with :success
    end

    it "it renders missing page if non existing user id given" do
      get user_path(-1)
      must_respond_with :missing
    end
  end
end
