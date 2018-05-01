require 'test_helper'

describe UsersController do

    describe 'index' do
      it "should get index for signed in users" do
        perform_login(users(:dan))
        get users_path
        must_respond_with :success
      end

      it "should render 404 for guest users" do
        get users_path
        must_respond_with :missing
      end
    end

    describe 'show' do
      it "should get show for signed in users" do
        perform_login(users(:dan))
        get user_path(users(:kari))
        must_respond_with :success
      end

      it "should render 404 for guest users" do
        get user_path(users(:kari))
        must_respond_with :missing
      end
    end

end
