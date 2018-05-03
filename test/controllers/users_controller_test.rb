require 'test_helper'

describe UsersController do

  describe "logged in users" do

    before do
      @user = User.last
    end

    describe "index" do
      it "succeeds when there are users" do
        # Assumption instead of Arrange
        # Check your assumption
        User.count.must_be :>, 0

        login(@user)
        # Act
        get users_path

        # Assert
        must_respond_with :success
      end
    end

    describe "show" do
      it "succeeds for an extant user ID" do
        login(@user)

        get user_path(@user.id)

        must_respond_with :success
      end

      it "renders 404 not_found for a bogus user ID" do
        login(@user)

        user_id = User.last.id + 1

        get user_path(user_id)

        must_respond_with :not_found
      end
    end
  end

  describe "guest user" do

    describe "index" do
      it "cannot let guest users access index" do

        # Act
        get users_path

        # Assert
        flash[:status].must_equal :failure
        flash[:result_text].must_equal "You must be logged in to view this section"
        must_respond_with :redirect
        must_redirect_to root_path
      end
    end

    describe "show" do
      it "cannot access for an extant user ID" do
        @user = User.first

        get user_path(@user.id)

        flash[:status].must_equal :failure
        flash[:result_text].must_equal "You must be logged in to view this section"
        must_respond_with :redirect
        must_redirect_to root_path
      end

      it "cannot access for a bogus user ID" do
        user_id = User.last.id + 1

        get user_path(user_id)

        flash[:status].must_equal :failure
        flash[:result_text].must_equal "You must be logged in to view this section"
        must_respond_with :redirect
        must_redirect_to root_path
      end
    end
  end
end
