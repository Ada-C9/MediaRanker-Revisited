require 'test_helper'

describe UsersController do

  describe "index" do

    before do

      @user_d = users(:dan)
      @user_k = users(:kari)

      @vote_1 = votes(:one)
      @vote_2 = votes(:two)
      @vote_3 = votes(:three)

      @vote_1.destroy
      @vote_2.destroy
      @vote_3.destroy

    end

    it "succeeds where there are no users" do

      @user_d.destroy
      @user_k.destroy
      get users_path
      must_respond_with :success

    end

    it "succeeds when there is one user" do

      @user_k.destroy
      get users_path
      must_respond_with :success

    end

    it "succeeds when there is more than one user" do

      get users_path
      must_respond_with :success

    end

  end

  describe "show" do

    it "succeeds for an extant user" do

      get user_path(users(:kari).id)
      must_respond_with :success

    end

    it "fails when the user doesn't exist" do

      bogus_id = 3
      User.find_by(id: bogus_id).must_be_nil
      get user_path(bogus_id)
      must_respond_with :not_found

    end

  end

end
