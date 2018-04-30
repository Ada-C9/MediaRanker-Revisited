require 'test_helper'

describe UsersController do

  describe "index" do
    it "succeeds with one user" do
      Vote.destroy_all
      User.destroy_all

      kari_data = {
        provider: "github",
        uid: 13371337,
        email: "kari@adaacademy.org",
        username: "kari"
      }
      kari = User.create!(kari_data)

      User.count.must_equal 1

      login(kari)
      get users_path
      must_respond_with :success
    end

    it "succeeds with many users" do
      User.count.must_be :>, 1

      login(users(:test))
      get users_path
      must_respond_with :success
    end
  end

  describe "show" do
    it "succeeds with one valid user" do
      Vote.destroy_all
      User.destroy_all
      User.count.must_equal 0
      kari_data = {
        provider: "github",
        uid: 13371337,
        email: "kari@adaacademy.org",
        username: "kari"
      }
      kari = User.create!(kari_data)

      User.count.must_equal 1

      login(kari)
      get user_path(User.find_by(username: "kari"))
      must_respond_with :success
    end

    it "succeeds with many valid users" do
      User.count.must_be :>, 1
      kari = User.find_by(username: "kari")
      dan = User.find_by(username: "dan")

      login(users(:test))
      get user_path(kari)
      must_respond_with :success

      get user_path(dan)
      must_respond_with :success
    end

    it "fails with invalid user" do
      invalid = User.count + 1

      login(users(:test))
      get user_path(invalid)
      must_respond_with :not_found
    end
  end

end
