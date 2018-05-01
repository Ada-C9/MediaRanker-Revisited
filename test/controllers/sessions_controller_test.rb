require "test_helper"

describe SessionsController do
  let (:user) { users(:kari) }

  describe "create" do
    it "logs in an existing user" do
      start_count = User.count
      login(user)

      must_redirect_to root_path

      session[:user_id].must_equal user.id
      User.count.must_equal start_count
    end

    it "logs in new user" do
      start_count = User.count
      user = User.new(provider: "github", uid: "1234", username: "test", email: "test@example.com")

      login(user)

      must_redirect_to root_path

      User.count.must_equal start_count + 1
      session[:user_id].must_equal User.last.id
    end

    it "does not login for bogus data" do
      start_count = User.count
      user = User.new(provider: "github", uid: "1234", username: nil, email: "test@example.com")

      login(user)

      must_redirect_to root_path

      User.count.must_equal start_count
      session[:user_id].must_be_nil
    end

  end

  describe "destroy" do
    it "can logout" do
      login(user)
      delete logout_path
      session[:user_id].must_be_nil
      must_redirect_to root_path
    end
  end

  # let (:user) { users(:kari) }
  # it "login_form" do
  #   get login_path
  #   must_respond_with :success
  # end
  # it "can log in" do
  #   post login_path, params: {
  #         username: "kari"
  #       }
  #
  #   must_redirect_to root_path
  # end
  #
  # it "can log out" do
  #   post logout_path
  #   must_redirect_to root_path
  #
  # end


end
