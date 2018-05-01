require 'test_helper'

describe UsersController do
  describe 'index' do
    it "should get index" do
      User.count.must_be :>, 0
      get users_path
      must_respond_with :success
    end

    it "should get delete" do
      Vote.destroy_all
      User.destroy_all
      get users_path
      must_respond_with :success
    end

  end

  describe 'show' do
    it "should respond to show" do
      get user_path(User.first)
      must_respond_with :success
    end

    it "should not show non-existant user " do
      get user_path(100)
      must_respond_with :not_found
    end

  end
end
