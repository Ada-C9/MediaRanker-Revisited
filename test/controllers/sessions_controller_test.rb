require "test_helper"

describe SessionsController do
  let(:dan) {users(:dan)}



  describe "login" do
    before do
      start_count = User.count
    end

    it "should login an existing user and redirect to root path" do
      proc { perform_login(users(:dan)) }.wont_change 'User.count'

      must_respond_with :redirect
      must_redirect_to root_path
      session[:user_id].must_equal dan.id
    end

     it "should successfully create a new user and login" do
      
        chris = User.new(
         provider: 'github',
         uid: 99999,
         email: 'chris@adadev.com',
         username: 'chris',
       )
       proc { perform_login(chris) }.must_change 'User.count', 1

       must_respond_with :redirect
       must_redirect_to root_path
       session[:user_id].must_equal User.last.id
     end
  end
end
