require "test_helper"

describe SessionsController do
  describe 'login method' do
    it 'should log in an existing user and redirect to root_path' do
      valid_fake_user = users(:dan)

      proc { perform_login(valid_fake_user) }.wont_change 'User.count'

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it 'should create a new user and successfully login' do
      new_user = User.new(
        provider: 'github',
        uid: 7654,
        email: 'dee@notreal.com',
        username: 'dee',
      )

      proc { perform_login(new_user) }.must_change 'User.count', 1

      must_respond_with :redirect
      must_redirect_to root_path
    end
  end
end
