require 'test_helper'

describe UsersController do
  describe "index" do
    it "succeeds when there are users" do
      # Assumption instead of Arrange
      # Check your assumption
      User.count.must_be :>, 0

      # Act
      get users_path

      # Assert
      must_respond_with :success
    end

    it "succeeds when there are no users" do
      # Arrange
      User.destroy_all

      # Act
      get users_path

      # Assert
      must_respond_with :success
    end
  end

  describe "show" do
    it "succeeds for an extant user ID" do
      get user_path(User.first)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus user ID" do
      user_id = User.last.id + 1

      get user_path(user_id)

      must_respond_with :not_found
    end
  end

end
