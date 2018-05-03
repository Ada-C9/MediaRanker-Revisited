require 'test_helper'

describe UsersController do

  describe "Logged in users" do
    before do
      @user = users(:dan)
    end

    describe "index" do
      it "succeeds when there are users" do
      login(@user)

        get users_path
        must_respond_with :success
      end
      end

    describe "show" do
      it "succeeds for an extant user ID" do
        login(@user)

        get user_path(users(:dan).id)
        must_respond_with :success
      end

      it "renders 404 not_found for a bogus user ID" do
        login(@user)

        get user_path("fake_id")
        must_respond_with :not_found
      end
    end
  end

  describe "Guest users" do
    describe "index" do
      it "cannot access users index" do
        get users_path

        flash[:status].must_equal :failure
        must_respond_with :redirect
        must_redirect_to root_path
      end
    end

    describe "show" do
      it "cannot access show for an extant user ID" do
        get user_path(users(:dan).id)

        flash[:status].must_equal :failure
        must_respond_with :redirect
        must_redirect_to root_path
      end

      it "cannot access show for a bogus user ID" do
        get user_path("Fake_user_id")

        flash[:status].must_equal :failure
        must_respond_with :redirect
        must_redirect_to root_path
      end
    end


  end
end
