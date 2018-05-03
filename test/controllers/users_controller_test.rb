require 'test_helper'

describe UsersController do
  describe "index" do
    it "succeeds when there are users" do
      user = User.first
      login(user)
      User.count.must_be :>, 0
      get users_path
      must_respond_with :success
    end

    it "succeeds when there are no users" do
      user = User.first
      login(user)
      User.destroy_all
      get root_path
      must_respond_with :success
    end
  end

  describe "show" do
    it "sends success if the user exist" do
      user = User.first
      login(user)
      get users_path("name")
      must_respond_with :success
    end

    it "sends not_found if the user does not exist" do
      user = User.first
      login(user)
      user_id = User.last.id + 1
      get user_path(user_id)
      must_respond_with :not_found
    end
  end
end
