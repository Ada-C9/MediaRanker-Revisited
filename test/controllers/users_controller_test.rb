require 'test_helper'

describe UsersController do
  describe "index" do
    describe "logged in user" do
      it "succeeds when there are users" do
        login(User.first)
        User.count.must_be :>, 0

        get users_path
        must_respond_with :success
      end
    end

    describe "guest user" do
      it "cannot access index" do
        get users_path
        must_respond_with :redirect
        must_redirect_to root_path
        flash[:result_text].must_equal "You must log in to do that"
      end
    end
  end

  describe "show" do
    describe "logged in user" do
      before do
        login(User.last)
      end

      it "succeeds for an existing user ID" do
        user_id = User.first.id

        get user_path(user_id)
        must_respond_with :success
      end

      it "renders 404 not_found for a bogus user ID" do
        user_id = User.last.id + 1

        get user_path(user_id)
        must_respond_with :not_found
      end
    end

    describe "guest user" do
      it "cannot access index" do
        user_id = User.first.id

        get user_path(user_id)
        must_respond_with :redirect
        must_redirect_to root_path
        flash[:result_text].must_equal "You must log in to do that"
      end
    end
  end
end
