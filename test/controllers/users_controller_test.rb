require 'test_helper'

describe UsersController do
  describe 'index' do
    it "succeeds with all Users" do
      User.count.must_be :>, 0
      get users_path
      must_respond_with :success
    end
    it 'sends a success response when there are no users' do
      User.destroy_all
      get users_path
      must_respond_with :success
    end
  end


  describe 'show' do
    it 'sends success if the user extant' do
      get user_path(User.first)
      must_respond_with :success
    end
    it 'sends not_found if the user is extinct' do
      user_id = User.last.id + 1
      get user_path(user_id)
      must_respond_with :not_found
    end
  end
end
