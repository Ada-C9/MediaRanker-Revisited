require 'test_helper'
require 'pry'

describe UsersController do

  describe 'guest user' do

    describe 'index' do
      it 'responds with unauthorized for a guest user' do
        User.count.must_be :>, 0
        get users_path
        must_respond_with :unauthorized
      end

    end # index

    describe 'show' do

      it 'responds with unauthorized for a guest user' do
        User.count.must_be :>, 0
        user = User.last
        get user_path(user)
        must_respond_with :unauthorized
      end

    end

  end # guest user

  describe 'logged-in user' do
    before do
      @user = User.first
    end

    describe 'index' do

      it 'succeeds when there is at least one user' do
        login(@user)

        User.count.must_be :>, 0
        get users_path
        must_respond_with :success
      end

      it 'succeeds when there are no users' do

        User.delete_all
        User.count.must_equal 0

        login(@user)
        get users_path

        must_respond_with :success
      end

    end # index

    describe 'show' do

      it 'responds with success for an extant user id' do
        login(@user)
        user = User.last

        get user_path(user)

        must_respond_with :success
      end

      it 'responds with not_found for a user that DNE' do
        login(@user)
        id = User.last.id + 1

        get user_path(id)

        must_respond_with :not_found
      end

    end # show
  end # logged-in user

end # UsersController
