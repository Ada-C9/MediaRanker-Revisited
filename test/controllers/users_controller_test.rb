require 'test_helper'

describe UsersController do

  describe "index" do
    it "succeeds when there are users" do

      User.count.must_be :>,0

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

      user = User.first

      get user_path(user.id)

      must_respond_with :success

    end

    it "renders 404 not_found for a bogus work ID" do

      get work_path(Work.last.id + 1)

      must_respond_with :not_found

    end
  end

end
