require 'test_helper'

describe UsersController do

  describe "index" do
    it "succeeds when there are users" do
      get users_path
      must_respond_with :success
      User.all.count.must_equal 2
    end

    it "succeeds when there are no users" do
      users(:dan).destroy
      users(:kari).destroy

      User.all.count.must_equal 0
      get users_path
      must_respond_with :success
    end
  end

  describe "show" do
    it "succeeds for an extant user ID" do
      get user_path(users(:dan).id)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus user ID" do
      users(:kari).id = 'testid'
      get user_path(users(:kari).id)
      must_respond_with :not_found
    end
  end
end
