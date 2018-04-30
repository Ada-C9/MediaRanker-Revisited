require 'test_helper'

describe UsersController do
  it 'creates a DB entry for a new user' do
    #arrange
    user = User.new(
      provider: 'github',
      uid: 80085,
      email: 'test@tester.com',
      name: 'test userr'
    )
    user.must_be :valid?
    old_user_count = User.count

    login(user)
    User.count.must_equal old_user_count + 1
    session[:user_id].must_equal User.last.id
  end
end
