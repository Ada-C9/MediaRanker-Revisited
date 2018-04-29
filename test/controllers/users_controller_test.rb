require 'test_helper'

describe UsersController do

  describe 'index' do

    it "sends a success response when there are many users" do
      User.count.must_be :>, 0

      get users_path

      must_respond_with :success
    end

    it "sends a success response when there are no users" do
      User.destroy_all

      get users_path

      must_respond_with :success
    end

  end

  describe 'show' do

    it "sends a success response when the user exists" do

      get user_path(User.first)

      must_respond_with :success

    end

    it "responds with not_found if the user doesn't exist" do

      user = User.last.id + 1

      get user_path(user)

      must_respond_with :not_found

    end

  end

end
