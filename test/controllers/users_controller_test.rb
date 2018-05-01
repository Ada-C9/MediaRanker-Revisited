require 'test_helper'

describe UsersController do
  before do
    user = users(:dan)
    login(user)
  end
    
  describe 'index' do
    it 'must respond with success if there is more than one user' do
      get users_path

      must_respond_with :success
    end

    it 'must respond with success if there are no users' do
      User.destroy_all

      get users_path

      must_respond_with :success
    end
  end

  describe 'show' do
    it 'must respond with success if the user is found' do
      user = User.first

      get user_path(user.id)

      must_respond_with :success
    end

    it 'must respond with 404 not found if the user is not found' do
      user_id = User.last.id + 1

      get user_path(user_id)

      must_respond_with :not_found
    end
  end
end
