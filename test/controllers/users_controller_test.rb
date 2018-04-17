require 'test_helper'

describe UsersController do
  describe 'Index' do
    it "succeeds when there are users" do
      #  Act
      get users_path
      # Assert
      must_respond_with :success
    end

    it "succeeds when there are no users" do
      # Arrange
      Work.destroy_all
      User.destroy_all
      assert User.all.empty?

      # Act
      get users_path

      #  Assert
      must_respond_with :success
    end
  end

  describe 'Show' do
    it "renders 404 not_found for a wrong user ID" do
      get work_path("wrong id")

      must_respond_with :missing
    end

  end
end
