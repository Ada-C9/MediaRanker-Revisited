require "test_helper"

describe SessionsController do

  describe 'auth_callback' do

    it 'creates a DB entry for a new user' do
      skip
      # Arrange
      user = User.new(
        username: "test username",
        email: "test@ada.com",
        uid: "124",
        provider: "github"
      )

      user.must_be :valid?
      old_user_count = User.count

      # Act
      login(user)

      # Assert
      # TODO: fix the respond with. Slacked Dan.
      # must_respond_with :redirect
      must_redirect_to root_path
      User.count.must_equal old_user_count + 1
      session[:user_id].must_equal User.last.id
    end

    it 'logs in a existing user' do
      # Arrange
      user = User.first
      old_user_count = User.count

      # Act
      login(user)

      # Assert
      User.count.must_equal old_user_count
      session[:user_id].must_equal user.id
    end

    it 'does not log in with insufficient data' do
      # Auth hash does not include a uid
      user = User.new(
        provider: 'github',
        email: 'mail@me.org',
        username: 'Milkah Lamb'
      )
      original_count = User.count

      # act
      login(user)

      # assert
      session[:user_id].must_equal nil
      User.count.must_equal original_count
      flash.now[:status].must_equal :failure
      flash.now[:result_text].must_equal "Could not log in"
    end
  end

  describe 'logout' do
    it "should be able to logout user" do
      # Arrange
      user = User.first
      login(user)

      # Act
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))

      delete logout_path


      session[:user_id].must_equal nil
      flash[:status].must_equal :success
      flash[:result_text].must_equal "Successfully logged out"
      must_respond_with :redirect
      must_redirect_to root_path
    end
  end
end
