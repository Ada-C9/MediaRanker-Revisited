require 'test_helper'

describe UsersController do
  describe "index" do
    it "succeeds when there are users" do
      get users_path
      must_respond_with :success
    end

    it "succeeds when there are no users" do

      users = User.all
      users.each do |user|
        user.votes.destroy
        user.destroy
      end
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
      get user_path(789)
      must_respond_with 404
    end
  end

end
