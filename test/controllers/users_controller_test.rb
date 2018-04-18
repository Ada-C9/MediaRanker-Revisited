require 'test_helper'

describe UsersController do

  describe "index" do

  it "succeeds to get all users" do

    get users_path
    must_respond_with :success
  end
end

  describe "show" do
    it "succeeds for an extistant user " do
      get user_path(users(:kari).id)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus user" do
      get user_path("chris")
      must_respond_with 404
    end
  end

end
