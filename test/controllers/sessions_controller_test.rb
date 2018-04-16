require "test_helper"

describe SessionsController do
  describe "login" do
    it "succeeds with new user" do
      proc {
          post login_path, params: {
            username: "Lillers"
        }
      }.must_change "User.count", 1

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "succeeds with existing user" do
      post login_path, params: {
        username: "dan"
      }
      session[:user_id].must_equal User.find_by(username: "dan").id
      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "succeeds with no media" do
      Work.all.each do |work|
        work.destroy
      end

      Work.count.must_equal 0
      post login_path, params: {
        username: "dan"
      }

      session[:user_id].must_equal User.find_by(username: "dan").id
      must_respond_with :redirect
      must_redirect_to root_path
    end
  end

  describe "logout" do
    it "redirects to the work page after the user has logged out" do
      post logout_path, params: {
        user: {
          username: "dan"
        }
      }

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "reverts the session[:user_id] to nil" do
      post login_path, params: {
        username: "dan"
      }

      session[:user_id].must_equal User.find_by(username: "dan").id

      post logout_path, params: {
        user: {
          username: "dan"
        }
      }

      session[:user_id].must_be_nil
    end
  end
end
