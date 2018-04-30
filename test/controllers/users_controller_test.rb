require 'test_helper'

describe UsersController do

  describe "index" do

    before do

      @user_d = users(:dan)
      @user_k = users(:kari)
      @user_1 = users(:user_1)
      @user_2 = users(:user_2)
      @user_3 = users(:user_3)
      @user_4 = users(:user_4)

      @vote_1 = votes(:one)
      @vote_2 = votes(:two)
      @vote_3 = votes(:three)

      @vote_1.destroy
      @vote_2.destroy
      @vote_3.destroy

    end

    it "succeeds when there is one user" do

      login(@user_d)

      @user_k.destroy
      @user_1.destroy
      @user_2.destroy
      @user_3.destroy
      @user_4.destroy

      get users_path
      must_respond_with :success

    end

    it "succeeds when there is more than one user" do

      login(@user_d)

      get users_path
      must_respond_with :success

    end

  end


  describe "show" do

    it "fails for a guest user" do

      get user_path(users(:kari).id)
      must_respond_with :redirect
      must_redirect_to github_login_path

    end

    it "succeeds for an extant user" do

      login(users(:dan))

      get user_path(users(:kari).id)
      must_respond_with :success

    end

    it "fails when the user doesn't exist" do

      login(users(:kari))

      bogus_id = 12
      User.find_by(id: bogus_id).must_be_nil
      get user_path(bogus_id)
      must_respond_with :not_found

    end

  end

end
