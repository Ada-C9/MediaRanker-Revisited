require 'test_helper'

describe UsersController do

  describe "logged in users" do
    before do
      user = users(:grace)
      login(user)
    end

    describe "index" do
      it "succeeds when there are users" do

        get users_path
        must_respond_with :success
      end
    end

    describe "show" do
      it "succeeds for an extant user ID" do
        user = users(:ada)

        get user_path(user.id)
        must_respond_with :success
      end

      it "renders 404 not_found for a bogus user ID" do
        get user_path("abc")
        must_respond_with :not_found
      end
    end
  end
end
