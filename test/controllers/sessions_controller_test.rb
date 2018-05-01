require "test_helper"

describe SessionsController do
  before do
    @kari = users(:kari)
    @dan = users(:dan)
    @ada = users(:ada)
    @rihanna = users(:rihanna)
  end

  describe 'Create' do
    it 'can create a new valid user from Github' do
      # Create a new user that does not exist in fixture
      @riley = {
        username: "RileytheCoder",
        email: "notyetauser@gmail.com",
        uid: 1001,
        provider: "Github"
      }

      @riley_git_hash = {
        provider: "Github",
        uid: 1001,
        info: {
          email: "notyetauser@gmail.com",
          nickname: "RileytheCoder"
        }
      }

      # Create mock account with user
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(@riley_git_hash)
      get auth_callback_path(:github)

      # New user must not exist in DB, new account will be generated.
      @user.must_be_nil
      flash[:result_text].must_equal "Your account has been generated #{@riley[:username]}!"

      User.last.username.must_equal @riley[:username]
      User.last.uid.must_equal  @riley[:uid]
      User.last.email.must_equal @riley[:email]
      session[:user_id].must_equal User.last.id

      must_respond_with :redirect
      must_redirect_to root_path
    end

     it 'will recognize an existing user' do
       login(@dan)
       session[:user_id].must_equal @dan.id

       flash[:status].must_equal :success
       flash[:result_text].must_equal "Logged in successfully, welcome back #{@dan.username}"

       must_respond_with :redirect
       must_redirect_to root_path
     end
     
     it 'will not create a user whose uid is non-existant (nil)' do
       @bad_git_data = {
         provider: "Github",
         uid: nil,
         info: {
           email: "bad-info@gmail.com",
           nickname: "No-uid"
         }
       }

       OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(@bad_git_data)
       get auth_callback_path(:github)

       flash[:status].must_equal :failure
       flash[:result_text].must_equal "Log in has failed"
       session[:user_id].must_be_nil
     end

     it 'will not create a user whose Git profile has missing information' do
       # Create a new user that does not exist in fixture & whose profile will violate model validation.

       @riley_git_hash_no_username = {
         provider: "Github",
         uid: 1001,
         info: {
           email: "Bad-data@gmail.com",
           nickname: nil
         }
       }

       # Create mock account with user
       OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(@riley_git_hash_no_username)
       get auth_callback_path(:github)
       flash[:status].must_equal :failure
       flash[:result_text].must_equal "Something has gone wrong in the account generation process."

     end
  end

  describe 'Destroy' do
    it 'will log out a user' do
      # Confim user has been logged in
      login(@kari)
      session[:user_id].must_equal @kari.id

      # Delete a user
      delete logout_path

      # Confirm user has been deleted
      session[:user_id].must_be_nil
      flash[:status].must_equal :success
      flash[:result_text].must_equal "You've logged out"

      must_respond_with :redirect
      must_redirect_to root_path
    end
  end
  # before do
  #   @dan = users :dan
  #   @kari = users :kari
  # end
  # describe 'Login' do
  #   it 'will allow an existing user to log back in and recall their username' do
  #
  #
  #     # # Confirm the user has been logged in
  #     # post login_path({
  #     #   username: @kari.username
  #     # })
  #     #
  #     # session[:user_id].must_equal @kari.id
  #     # flash[:status].must_equal :success
  #     # flash[:result_text].must_equal "Successfully logged in as existing user #{@kari.username}"
  #   end

    # it 'will create an account for a new valid user' do
    #   post login_path({
    #     username: "Larry Croix"
    #     })
    #
    #   session[:user_id].must_equal User.last.id
    #   flash[:status].must_equal :success
    #   flash[:result_text].must_equal "Successfully created new user #{User.last.username} with ID #{User.last.id}"
    # end

    # it 'will render a bad_requst for a user who attempts to create an account with invalid data' do
    #   post login_path({
    #     username: " "
    #     })
    #     flash.now[:status].must_equal :failure
    #     flash.now[:result_text].must_equal "Could not log in"
    #     assert_operator flash.now[:messages][:username].size,:>, 0
    #
    #     must_respond_with :bad_request
    #
    # end
  # end

  # describe 'Logout' do
  #   it 'will destroy an existing account' do
  #
  #     proc{
  #         post logout_path({username: @dan.username})
  #       }.wont_change 'User.count'
  #
  #     session[:user_id].must_be_nil
  #     flash[:status].must_equal :success
  #     flash[:result_text].must_equal "Successfully logged out"
  #
  #     must_respond_with :redirect
  #     must_redirect_to root_path
  #   end
  # end
  #
  # describe 'Login Form' do
  #   it 'success' do
  #     get login_path({
  #       username: @kari.username
  #       })
  #     must_respond_with :success
  #   end
  # end
end
