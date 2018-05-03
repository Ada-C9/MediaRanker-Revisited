require 'test_helper'

describe UsersController do
  before do
    @user = users(:dan)
  end

  describe 'index' do
    it 'succeeds for logged in users' do
      login(@user)

      get users_path
      must_respond_with :success
    end

    it 'cannot access index for guest users' do
      get users_path
      flash[:status].must_equal :failure
      flash[:result_text].must_equal "You must be logged in to view this page"
      must_respond_with :redirect
      must_redirect_to root_path
    end
  end

  describe 'show' do

    it 'succeeds for logged in user with an extant ID' do
      login(@user)

      get user_path(users(:dan).id)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus user ID" do
        login(@user)

        get user_path("baa")

        must_respond_with :not_found
      end

    it 'cannot access show page for a guest user with extant ID' do
      get user_path(users(:dan).id)

      flash[:status].must_equal :failure
      flash[:result_text].must_equal "You must be logged in to view this page"
      must_respond_with :redirect
      must_redirect_to root_path
    end

    it 'cannot access show page for guest user with a bogus user ID' do
      get user_path(users(:dan).id)

      flash[:status].must_equal :failure
      flash[:result_text].must_equal "You must be logged in to view this page"
      must_respond_with :redirect
      must_redirect_to root_path
    end


  end
end
