require "test_helper"

describe SessionsController do

  describe "login" do
    it 'succeeds at finding login path' do
      get login_path
      must_respond_with :success
    end
  end

  describe "logout" do
    it 'succeeds at if no user' do
      get logout_path
      must_respond_with :success
    end
  end

end
