require "test_helper"

describe SessionsController do
  describe 'create' do
    it 'succeeds when an existing user logs in' do
      start_count = User.count
      user = users(:kari)

      login(user)

      must_respond_with :redirect
      must_redirect_to root_path
      session[:user_id].must_equal user.id
    end
  end
end
