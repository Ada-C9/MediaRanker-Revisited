require 'test_helper'

describe UsersController do
  let(:bogus_id) { "id" }
  let(:user) { users(:grace) }

  describe "index" do
    it "succeeds when there are users" do
      login(user)
      get users_path
      must_respond_with :success
    end
  end

  describe "show" do
    it "succeeds with a valid id" do
      login(user)
      get user_path(users(:dan).id)
      must_respond_with :success
    end

    it "responds with 404 not found for bogus id" do
      login(user)
      get user_path(bogus_id)
      must_respond_with :not_found
    end
  end
end
