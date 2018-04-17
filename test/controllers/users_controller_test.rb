require 'test_helper'

#should have about 4 tests here
# test index
# and text show

describe UsersController do

  describe "index" do
    it "succeeds when there are users" do

      get users_path
      must_respond_with :success
    end

    it "succeeds when there are no users" do
      # User.all.each do |user|
      #   user.votes.destroy_all
      # end

      User.destroy_all
      get users_path
      must_respond_with :success
    end
  end

  describe "show" do
    it "succeeds for an existent user ID" do
      get users_path(users(:kari).id)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus user ID" do
      users(:dan).id = 'notanid'

      get user_path(users(:dan).id)

      must_respond_with :not_found
    end
  end

end
