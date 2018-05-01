require 'test_helper'

describe UsersController do

  describe 'index' do

    it 'succeeds when there is at least one user' do
      User.count.must_be :>, 0
      get users_path
      must_respond_with :success
    end

    it 'succeeds when there are no users' do
      User.delete_all
      User.count.must_equal 0

      get users_path

      must_respond_with :success
    end

  end # index

  describe 'show' do
  end # show

end # UsersController
