require 'test_helper'

describe UsersController do
  describe "index" do
    it "succeeds when there are users" do
      User.count.must_equal 2
      get users_path
      must_respond_with :success
    end

    it "succeeds when there are no users" do
        Vote.all.each do |vote|
          vote.destroy
        end

        User.all.each do |person|
          person.destroy
        end

        User.count.must_equal 0
        get users_path
        must_respond_with :success
    end
  end

  describe "show" do
    it "succeeds when the user exists" do
      get user_path(users(:kari).id)
      must_respond_with :success
    end

    it "fails when the user does not exist" do
      get user_path("carrot")
      must_respond_with :not_found
    end
  end

end
