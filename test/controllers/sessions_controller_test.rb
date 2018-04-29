require "test_helper"

describe SessionsController do
  before do
    @dan = users :dan
    @kari = users :kari
  end
  describe 'Login' do
    it 'will allow an existing user to log back in and recall their username' do
      # Confirm the user has been logged in
      post login_path({
        username: @kari.username
      })

      session[:user_id].must_equal @kari.id
      flash[:status].must_equal :success
      flash[:result_text].must_equal "Successfully logged in as existing user #{@kari.username}"
    end

    it 'will create an account for a new valid user' do
      post login_path({
        username: "Larry Croix"
        })

      session[:user_id].must_equal User.last.id
      flash[:status].must_equal :success
      flash[:result_text].must_equal "Successfully created new user #{User.last.username} with ID #{User.last.id}"
    end

    it 'will render a bad_requst for a user who attempts to create an account with invalid data' do
      post login_path({
        username: " "
        })
        flash.now[:status].must_equal :failure
        flash.now[:result_text].must_equal "Could not log in"
        assert_operator flash.now[:messages][:username].size,:>, 0

        must_respond_with :bad_request

    end
  end

  describe 'Logout' do
    it 'will destroy an existing account' do

      proc{
          post logout_path({username: @dan.username})
        }.wont_change 'User.count'

      session[:user_id].must_be_nil
      flash[:status].must_equal :success
      flash[:result_text].must_equal "Successfully logged out"
      
      must_respond_with :redirect
      must_redirect_to root_path
    end
  end

  describe 'Login Form' do
    it 'success' do
      get login_path({
        username: @kari.username
        })
      must_respond_with :success
    end
  end
end
