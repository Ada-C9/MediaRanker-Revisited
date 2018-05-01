require "test_helper"

describe SessionsController do
  # it "must be a real test" do
  #   flunk "Need real tests"
  # end
  describe 'auth_callback' do
    it 'logs in an existing user' do
      #arrange
      user = User.first

      old_user_count = User.count

      login(user)

      User.count.must_equal old_user_count
      session[:user_id].must_equal user.id
    end

    it 'does not log in with insufficient data' do
      #Auth hash does not include a uid
      user = User.new(
        uid: 80085,
        username: ''
      )
      user.wont_be :valid?
      old_user_count = User.count

      login(user)
      User.count.must_equal old_user_count
    end

    it 'does not log in if the user data is invalid' do
      old_user_count = User.count

      exist_user = User.first
      username = exist_user.username

      user = User.new(
        provider: 'github',
        uid: 80085,
        email: 'test@tester.com',
        username: username
      )
      user.wont_be :valid?
      login(user)
      get root_path

      User.count.must_equal old_user_count
    end

    it 'can logout of a user session' do
      user = User.first
      login(user)
      session[:user_id].must_equal user.id

      delete logout_path
      must_respond_with :redirect
      session[:user_id].must_be_nil
    end

  end
end
