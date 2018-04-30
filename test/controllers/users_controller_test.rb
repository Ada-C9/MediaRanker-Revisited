require 'test_helper'

#should have about 4 tests here
# test index
# and text show

describe UsersController do

  describe "index" do
    it "succeeds when there are users" do
      perform_login(users(:grace))
      get users_path
      must_respond_with :success
    end

    it 'redirects to root if there is no logged in user' do
      get users_path

      must_respond_with :redirect
      must_redirect_to root_path
    end
  end

  describe "show" do
    it "succeeds for an existent user ID" do
      perform_login(users(:kari))
      get users_path(users(:kari).id)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus user ID" do
      perform_login(users(:dan))
      users(:dan).id = 'notanid'

      get user_path(users(:dan).id)

      must_respond_with :not_found
    end
  end

end
