require "test_helper"

describe SessionsController do
  describe "login" do
   it "should log in an existing user and redirect to the root " do
     existing_user = users(:ada)

     proc {
       perform_login(existing_user)
     }.must_change 'User.count', 0

     session[:user_id].must_equal existing_user.id
     flash[:status].must_equal :success
     flash[:result_text].must_equal "Successfully logged in as existing user ada"
     must_respond_with :redirect
     must_redirect_to root_path
   end

   it "should create a new user and redirect to the root  if given valid user data" do
     new_user = User.new(
       provider: 'github',
       uid: 999,
       email: 'test@test.com',
       username: 'test user'
     )

     proc {
       perform_login(new_user)
     }.must_change 'User.count', 1

     user_id = User.all.find_by(uid: 999).id

     session[:user_id].must_equal user_id
     flash[:status].must_equal :success
     flash[:result_text].must_equal "Successfully created new user test user with ID #{user_id}"
     must_respond_with :redirect
     must_redirect_to root_path
   end

   it "should redirect to the root if given bogus user data" do
     bogus_user = User.new(
       provider: 'github',
     )

     proc {
       perform_login(bogus_user)
     }.must_change 'User.count', 0

     session[:user_id].must_equal nil
     flash.now[:status].must_equal :failure
     flash.now[:result_text].must_equal "Logging in through GitHub not successful"
     must_respond_with :redirect
     must_redirect_to auth_callback_path
   end
 end

 describe "logout" do
   it "should log out user and redirect to the root" do
     current_user = users(:ada)
     perform_login(current_user)

     perform_logout(current_user)

     session[:user_id].must_equal nil
     flash[:status].must_equal :success
     flash[:result_text].must_equal "Successfully logged out"
     must_respond_with :redirect
     must_redirect_to root_path
   end
 end

end
