require 'test_helper'

describe UsersController do
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
end
