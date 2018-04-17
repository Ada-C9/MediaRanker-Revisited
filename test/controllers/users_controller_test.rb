require 'test_helper'

describe UsersController do
  describe 'index' do
    it 'works with lots of users' do
      User.count.must_be :>,0

      get users_path
      must_respond_with :success
    end

    it 'works with no users' do
      User.destroy_all

      get users_path
      must_respond_with :success
    end
  end

  # TODO: WRITE TESTS FOR USER SHOW
  describe 'show' do
    it 'works for a real exsisting user' do
      skip
    end

    it 'renders not found (404) for a non-exsistent user' do
      skip
    end
  end
end
