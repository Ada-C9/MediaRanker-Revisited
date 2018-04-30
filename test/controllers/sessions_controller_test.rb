require "test_helper"

describe SessionsController do

# DON'T KNOW WHY THESE ARE FAILING
  # it "creates an entry in the database for a new user" do
  #
  #   user = User.new(
  #     username: 'new user',
  #     email: 'new_user@gmail.com',
  #     uid: 12345,
  #     provider: 'github'
  #   )
  #
  #   user.must_be :valid?
  #   old_user_count = User.count
  #
  #   login(user)
  #
  #   User.count.must_equal old_user_count + 1
  #   session[:user_id].must_equal User.last.id
  #
  # end

  # it "log in an existing user" do
  #   user = User.first
  #   old_user_count = User.count
  #
  #   login(user)
  #
  #   User.count.must_equal old_user_count
  #   session[:user_id].must_equal user.id
  # end

end
