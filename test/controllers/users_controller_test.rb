require 'test_helper'

describe UsersController do
  describe "auth_callback" do
    it "logs in an existing user and redirects to the root route" do
      start_count = User.count

      user = users(:dan)

      login(user)

      must_redirect_to root_path

      session[:user_id].must_equal user.id

      User.count.must_equal start_count
    end

    it "creates an account for a new user and redirects to the root route" do
      start_count = User.count
      user = User.new(provider: "github", uid: 99999, username: "test_user", email: "test@user.com")

      login(user)

      must_redirect_to root_path
      User.count.must_equal start_count + 1
      session[:user_id].must_equal User.last.id
    end

    describe "Logged in users" do
      before do
        login(users(:kari))
      end

      describe "index" do
        it "succeeds with at least 1 user" do
          User.all.nil?.must_equal false
          get users_path
          must_respond_with :success
        end

        it "redirects to root with no users" do
          Vote.destroy_all
          User.destroy_all
          User.count.must_equal 0
          get users_path
          must_respond_with :redirect
          must_redirect_to :root
        end
      end

      describe "show" do
        it "succeeds with existing user" do
          user = users(:dan)
          get user_path(user.id)
          must_respond_with :success
        end

        it "it renders missing page if non existing user id given" do
          get user_path(-1)
          must_respond_with :missing
        end
      end
    end

    describe "Guest users" do
      before do
        delete logout_path
      end

      describe "index" do
        it "redirects to root with at least 1 user" do
          User.all.nil?.must_equal false
          get users_path
          must_respond_with :redirect
          must_redirect_to :root
        end

        it "redirects to root with no users" do
          Vote.destroy_all
          User.destroy_all
          User.count.must_equal 0
          must_respond_with :redirect
          must_redirect_to :root
        end
      end

      describe "show" do
        it "redirects to root with guest user" do
          user = users(:kari)
          get user_path(user.id)
          must_respond_with :redirect
          must_redirect_to :root
        end

        it "it redirects to root if non existing user id given" do
          get user_path(-1)
          must_respond_with :redirect
          must_redirect_to :root
        end
      end
    end
  end
end
