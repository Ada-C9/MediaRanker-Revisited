require 'test_helper'

describe UsersController do
  describe "index" do
    it "sends a success response when there are many users" do
      User.count.must_be :>, 0

      get users_path

      must_respond_with :success
    end

    it "sends a success response when there are no users" do
      Vote.destroy_all
      User.destroy_all

      get users_path

      must_respond_with :success
    end
  end

  describe "show" do
    it "sends a success response when the current user requests their show page" do
      current_user = User.first
      get user_path(current_user)

      must_respond_with :success
    end

    it "renders 404 if user requests show page that doesn't correspond to their id" do
      current_user_id = User.first.id
      get user_path(current_user_id + 1)

      must_respond_with :not_found
    end

    it "renders 404 if user's id doesn't exist" do
      current_user_id = User.first.id
      User.first.votes.destroy_all
      User.first.delete

      get user_path(current_user_id)
      must_respond_with :not_found
    end
  end
end
