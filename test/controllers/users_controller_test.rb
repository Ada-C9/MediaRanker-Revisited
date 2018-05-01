require 'test_helper'

describe UsersController do
  let(:ada) { users(:ada) }

  describe "index" do
    it "succeeds when there are users" do
      perform_login(ada)
      get users_path
      must_respond_with :success
      User.all.count.must_equal 4
    end

    it "succeeds when there are no users" do
      users(:dan).destroy
      users(:kari).destroy
      users(:ada).destroy
      users(:grace).destroy

      User.all.count.must_equal 0
      perform_login(ada)
      get users_path
      must_respond_with :success
    end
  end

  describe "show" do
    it "succeeds for an extant user ID" do
      perform_login(ada)
      get user_path(users(:dan).id)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus user ID" do
      kari = users(:kari)
      kari.id = 'testid'
      perform_login(ada)
      get user_path(kari.id)
      must_respond_with :not_found
    end
  end
end
