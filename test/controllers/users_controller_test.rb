require 'test_helper'

describe UsersController do

  describe "logged in user" do
    before do
      @user = users(:kari)
    end

    describe "index" do
      it "sends a success response when there are many users" do
        login(@user)
        User.count.must_be :>, 0

        get users_path

        must_respond_with :success
      end

      it "sends a success response when there are no users" do

      end
    end

    describe "show" do
      it "sends a success response when the current user requests their show page" do
        login(@user)
        get user_path(@user)

        must_respond_with :success
      end

      it "renders 404 if user requests show page that doesn't correspond to their id" do
        current_user_id = @user.id
        login(@user)
        get user_path(current_user_id + 1)

        must_respond_with :not_found
      end

      it "renders 404 if user's id doesn't exist" do
        login(@user)

        get user_path("test")
        must_respond_with :not_found
      end
    end
  end

  describe "guest user" do
    describe "index" do
      it "can't view index" do
        get users_path

        must_respond_with :redirect
        must_redirect_to root_path
      end
    end

    describe "show" do
      it "can't see a user's show page" do
        user_id = users(:kari).id
        get user_path(user_id)

        must_respond_with :redirect
        must_redirect_to root_path
      end
    end
  end
  
end
