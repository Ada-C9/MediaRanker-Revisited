require 'test_helper'

describe UsersController do
  describe 'index' do
    it 'responds with success when users exist' do
      User.count.must_be :>, 0

      get users_path

      must_respond_with :success
    end

    it 'responds with success when no users' do

      User.all.each do |user|
        user.delete
      end

      User.count.must_equal 0

      get users_path

      must_respond_with :success
    end

  end

  describe 'show' do
      it 'responds with success when user exists' do
        user = User.first

        get user_path(user)

        must_respond_with :success
      end

      it 'render not_found when user exists' do
        user_id = User.last.id + 1

        get user_path(user_id)

        must_render :not_found
      end
  end

end
