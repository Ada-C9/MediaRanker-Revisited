require 'test_helper'

describe UsersController do
  describe 'Index' do
    it "should get index" do
      get users_path
      must_respond_with :success
  end
end

describe 'Show' do
  it "should be able to show a user's page" do

  get user_path(users(:dan).id)
  must_respond_with :success
end

  it "should render an HTTP response 404 for a value non-existant in databse. " do
  non_existant_id = 100000000
  get user_path(non_existant_id)
  must_respond_with :missing

  end
end

end
