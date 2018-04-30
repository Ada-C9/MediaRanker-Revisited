require 'test_helper'

describe UsersController do
  describe "guest user" do
    describe "index" do
      it "redirects to root_path when no user logged
      on" do
        User.count.must_equal 4
        get users_path

        session[:user_id].must_be_nil
        must_redirect_to root_path
      end
    end

    describe "show" do
      it "redirects to root_path when no user logged on" do
        random_user = users(:ada)

        User.count.must_equal 4
        get user_path(random_user.id)

        session[:user_id].must_be_nil
        must_redirect_to root_path
      end
    end
  end

  describe "logged in user" do
    describe "index" do
      it "succeeds when a user is logged in" do
          User.count.must_equal 4
          user = users(:ada)
          perform_login(user)
          get users_path

          session[:user_id].must_equal user.id
          must_respond_with :success
      end
    end

    describe "show" do
      it "succeeds when a user is logged in" do
        User.count.must_equal 4
        user = users(:ada)

        perform_login(user)
        get user_path(user.id)

        must_respond_with :success
      end

      it "fails when the user does not exist" do
        get user_path(User.last.id+1)


        must_redirect_to root_path
      end

    end
  end
end
