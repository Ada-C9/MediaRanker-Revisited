require 'test_helper'

describe UsersController do
  before do
    @rihanna = users(:rihanna)
    @ada = users(:ada)
    #login not working here?
  end
      describe 'Index' do
        it 'Should get index' do
          login(@rihanna)
          session[:user_id].must_equal @rihanna.id
          get users_path
          must_respond_with :success
        end
      end


    describe 'Show' do
      it "Should be able to show a user's page" do
        login(@rihanna)
        session[:user_id].must_equal @rihanna.id
        get user_path(users(:dan).id)
        must_respond_with :success
      end
      it 'should render an HTTP response 404 for a value non-existant in databse.' do
        login(@rihanna)
        session[:user_id].must_equal @rihanna.id
        non_existant_id = -1
        get user_path(non_existant_id)
        must_respond_with :missing
      end
    end


end
