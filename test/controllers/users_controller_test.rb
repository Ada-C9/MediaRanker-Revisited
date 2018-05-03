require 'test_helper'

describe UsersController do
  it "should respond with success" do

    get users_path

    must_respond_with :success

  end

  describe "show" do

    it "responds with success if user exists" do

      id = User.first.id

      get user_path(id)

      must_respond_with :success

    end

    it "must render 404 not found if user cant be found" do

      id = User.first.id + 10

      get user_path(id)

      must_respond_with :not_found

    end
  end
end
