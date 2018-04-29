require 'test_helper'

describe UsersController do
  describe 'index' do
    it 'succeeds when there are users and user is logged in' do
      perform_login(users(:dan))

      get users_path

      must_respond_with :success
    end
    it 'redirects to root if there is no logged in user' do
      get users_path

      must_respond_with :redirect
      must_redirect_to root_path
    end
  end
  describe 'show' do
    it 'succeeds for an extant work ID and user is logged in' do
      perform_login(users(:dan))
      user = users(:kari)

      get user_path(user.id)

      must_respond_with :success
    end
    it 'redirects to root if no one is logged in' do
      get user_path(users(:dan).id)

      must_respond_with :redirect
      must_redirect_to root_path
    end
    it 'renders 404 not_found for an invalid work ID' do
      user = users(:dan)
      id = user.id
      user.votes.each {|vote| vote.destroy }
      user.destroy

      perform_login(users(:kari))

      get user_path(id)

      must_respond_with 404
    end
  end
end
