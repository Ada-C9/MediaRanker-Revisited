require "test_helper"

# Arrange
# Assumptions
# Act
# Assert

describe SessionsController do
  # it "must be a real test" do
  #   flunk "Need real tests"
  # end

  describe 'sessions_create' do
    it 'creates a DB entry for a new user' do
      # Arrange
      user = User.new(
        username: 'some person',
        email: 'place@somewhere.org',
        uid: 11111111,
        provider: 'github'
      )
      user.must_be :valid?
      old_user_count = User.count

      # Act
      login(user)
      must_redirect_to root_path

      new_user = User.find_by(id: session[:user_id])
      result = new_user.uid

      result.must_equal user.uid

      # Assert
      User.count.must_equal old_user_count + 1
      session[:user_id].must_equal User.last.id
    end

    it 'logs an existing user' do
      # Arrange
      user = User.first
      old_user_count = User.count

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))

      # Act
      # get auth_callback_path(:github)  <-- don't need this because we put it in test_helper.rb file login(user) method
      login(user)

      # Assert
      # must_redirect_to root_path <-- don't need this because we put it in test_helper.rb file login(user) method
      User.count.must_equal old_user_count
      session[:user_id].must_equal user.id
    end

    it 'does not log in with insufficient data' do
      # if Github is broken - auth hash does not include a UID
      # Arrange
      user = User.new(
        username: 'some person',
        email: 'place@somewhere.org',
        provider: 'github'
      )
      old_user_count = User.count
      login(user)

      User.count.must_equal old_user_count
    end

    it 'does not log in if the user data is invalid' do
      # User.save didn't go off - validation fails
    end


    # What about if the user is already logged in?
  end
end
