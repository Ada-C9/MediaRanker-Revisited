require 'test_helper'

describe UsersController do

  describe "index" do

    it "succeeds where there are no users" do

      @users = nil

      get users_path
      must_respond_with :success

    end

    it "succeeds when there is one user" do

      get users_path
      must_respond_with :success

    end

    it "succeeds when there is more than one user" do

      get users_path
      must_respond_with :success

    end

  end

  describe "show" do

    it "succeeds for an extant user" do

      get user_path()
      must_respond_with :success
    end

    it "fails when the user doesn't exist" do

      get user_path()
      must_respond_with ---fail---

    end

  end

end
