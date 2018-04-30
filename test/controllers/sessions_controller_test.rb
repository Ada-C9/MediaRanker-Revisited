require "test_helper"

describe SessionsController do
  let (:user) { users(:kari) }
  it "login_form" do
    get login_path
    must_respond_with :success
  end
  it "can log in" do
    post login_path, params: {
          username: "kari"
        }

    must_redirect_to root_path
  end

  it "can log out" do
    post logout_path
    must_redirect_to root_path

  end

end
