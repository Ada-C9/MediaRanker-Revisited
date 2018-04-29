require 'test_helper'

describe UsersController do

  describe "index" do

    it "succeeds to get all users" do

      get users_path
      must_respond_with :success
    end

    it "succeeds when there are no users" do
      User.all.each do |user|
        user.votes.each do |vote|
          vote.destroy
        end
        user.destroy
      end

      get users_path
      must_respond_with :success
      User.all.count.must_equal 0
    end
  end

  describe "show" do
    it "succeeds for an existant user id " do
      get user_path(users(:kari).id)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus user id" do
      get user_path("chris")
      must_respond_with 404
    end

  end
end
