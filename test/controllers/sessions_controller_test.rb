require "test_helper"

describe SessionsController do

  before do
    @existing_user = users(:dan)

  end
  describe "login" do

    it 'login an existing user and redirect to root page' do
      old_user_count = User.count

      login(@existing_user)

      must_redirect_to root_path
      User.count.must_equal old_user_count
      session[:user_id].must_equal @existing_user.id
    end

    it 'creates a new user if given valid data and redirect to root page' do
      new_user = User.new(
        provider: "github",
        uid: 900,
        email: "test@adadevelopersacademy.org",
        username: "test name"
      )

      new_user.must_be :valid?
      old_user_count = User.count

      login(new_user)

      User.count.must_equal old_user_count + 1
      must_redirect_to root_path
      session[:user_id].must_equal User.last.id
      flash[:status].must_equal :success
      flash[:result_text].must_equal "Logged in new user successfully"
    end

    it 'does not create a new user if bogus data given and redirect to root page' do
      new_user = User.new(
        provider: "github",
        email: "dada@test.org",
        username: "coco"
      )

      old_user_count = User.count

      login(new_user)
      flash[:error].must_equal "Logging in through GitHub not successful"
      User.count.must_equal old_user_count
      must_redirect_to root_path
    end

  end

  describe "logout" do

    it 'should log out the user and redirect to root page' do
      user = User.first
      login(user)

      logout(user)

      session[:user_id].must_equal nil
      flash[:result_text].must_equal "Successfully logged out"
      must_respond_with :redirect
      must_redirect_to root_path
    end

  end
end
