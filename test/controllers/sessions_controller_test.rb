require "test_helper"

describe SessionsController do

  describe 'login' do

    before do
      @user = User.new(username: 'thebatman')
      @user.must_be :valid?
      @user.save
    end

    it 'responds with success for an extant user' do
      username = @user.username

      post login_path, params: { username: username }

      must_respond_with :redirect
      must_redirect_to root_path
      session[:user_id].must_equal @user.id
    end

    it 'responds with success for a new user' do
      User.delete_all
      User.count.must_equal 0
      username = 'thebatman'
      post login_path, params: { username: username }

      must_respond_with :redirect
      must_redirect_to root_path
      session[:user_id].wont_be_nil
      User.count.must_equal 1
    end

    it 'responds with bad_request for a new user with an empty username' do
      User.delete_all
      User.count.must_equal 0
      username = ''
      post login_path, params: { username: username }

      must_respond_with :bad_request
      session[:user_id].must_be_nil
      User.count.must_equal 0
    end

  end # login

  describe 'logout' do 
  end # logout

end # SessionsController
