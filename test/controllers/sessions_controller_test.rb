require "test_helper"

describe SessionsController do


  describe "login" do
    it "succeeds with an existing username and redirects to root_path" do
      existing_user = users(:dan)

      perform_login(existing_user)

      must_redirect_to root_path

    end

    it "succeeds with new valid username and redirects to root path" do
      #not sure why these tests don't work!
      new_user = User.new(
        provider: 'githib',
        uid: 999,
        username: 'test user',
        email: 'test@test.com'
      )

      proc {
        perform_login(new_user)
      }.must_change 'User.count', 1


      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "renders bad_request with invalid username" do
      skip
      new_user = User.new(
        provider: 'githib',
        uid: 999,
        username:'',
        email: 'test@test.com'
      )

      proc {
        perform_login(new_user)
      }.must_change 'User.count', 0


      must_respond_with :bad_request
    end
  end

  describe "logout" do
    it "changes session user id to nil" do
      existing_user = users(:dan)

      perform_login(existing_user)

      session[:user_id].must_equal users(:dan).id
      post logout_path
      session[:user_id].must_equal nil
    end

    it "succeeds if no user is logged in" do
      post logout_path
      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "succeeds if user is logged in" do
      post login_path, params: {
        username: users(:dan)
      }
      post logout_path

      must_respond_with :redirect
      must_redirect_to root_path
    end
  end

end
