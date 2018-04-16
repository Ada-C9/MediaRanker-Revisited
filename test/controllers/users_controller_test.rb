require 'test_helper'

describe UsersController do
describe "index" do
  it "lists all users" do
    get users_path
    must_respond_with :success
  end

end

describe "show" do
  it "displays a user with existant id" do
    user = User.first

    get user_path(user)
    must_respond_with :success
  end

  it "renders missing for a bogus id" do
    user_id = User.last.id + 1

    get user_path(user_id)
    must_respond_with :missing

  end
end
end
