require "test_helper"

describe SessionsController do

    describe "auth_callback" do
    it "should log in an existing user and redirects them back to the homepage" do
      start_count = User.count
      user = users(:ari)

      #Action
      login(user)
      #Assert
      must_respond_with :redirect
      must_redirect_to root_path
      User.count.must_equal start_count
      session[:user_id].must_equal user.id
    end

    it "can login a new user" do
      start_count = User.count
      user = User.new(
        username: "Greg",
        provider: 'github',
        email: 'Greg@gmail.com',
        uid: 901 )

      login(user)

      #Assert
      must_respond_with :redirect
      # must_redirect_to root_path
      User.count.must_equal (start_count + 1)
      session[:user_id].must_equal User.last.id
    end

    it 'logs in an existing user' do
      # Arrange
      start_count = User.count
      user = User.first

      # Act
      login(user)

      # Assert
      User.count.must_equal start_count
      session[:user_id].must_equal user.id
    end

    it 'does not login if the user data is invalid' do
      # Validations fails
      user = User.new(
      uid: 99999,
      provider: "github",
      email: nil,
      username: nil)

      login(user)

      must_respond_with :redirect
      must_redirect_to root_path
      # session[:user_id].must_equal nil
    end

    it 'does not log in with insufficient data' do
      start_count = User.count

      user = User.new(
        provider: "github",
        username: 'something',
        uid: 99999)

      login(user)

      User.count.must_equal start_count
      # Auth hash doesn not include a uid
    end
  end

  describe 'logout' do
    it "can logout a user" do
      login(users(:ari))
      session[:user_id].must_equal users(:ari).id

      post logout_path
      must_respond_with :redirect
      must_redirect_to root_path
    end
  end
end
