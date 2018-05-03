require "test_helper"

describe SessionsController do

  describe "create" do

    it "logs in returning user" do
      user = User.first

      user_count = User.count

      login(user)

      User.count.must_equal user_count
      session[:user_id].must_equal user.id

    end

    it "creates a new user with valid data" do

      user = User.new(provider: 'github', uid: 76107, email: 'mail4@me.org', username: 'Jinny Larrimer')

      user_count = User.count
      user.must_be :valid?

      login(user)


      User.count.must_equal user_count + 1
      session[:user_id].must_equal user.id

    end

    it "does not create a new session with invalid data" do
      user = User.new(provider: 'github', uid: nil , email: 'mail@me.org', username: 'Stokely Corrimer')

      user_count = User.count
      user.wont_be :valid?

      login_path(user)


      must_respond_with :bad_request

      User.count.must_equal user_count

      session[:user_id].must_equal nil

    end
  end


  describe "destroy" do

    it "destroys session on logout" do

      login(User.first)

      User.first.destroy

      session[:user_id].must_equal nil

    end
  end


  # user = User.first
  # old_user_count = User.count
  #
  # # login(user)
  #
  # User.count.must_equal old_user_count
  # session[:user_id].must_equal user.id
  #
  #
  # new_user = User.new(username: "thinking", provider: "github", uid: 90808, email: "test@testy.org", name: 'Alum Mcallster' )
  #
  # new_user.save



end
