require 'test_helper'

describe User do
  describe "relations" do
    it "has a list of votes" do
      dan = users(:dan)
      dan.must_respond_to :votes
      dan.votes.each do |vote|
        vote.must_be_kind_of Vote
      end
    end

    it "has a list of ranked works" do
      dan = users(:dan)
      dan.must_respond_to :ranked_works
      dan.ranked_works.each do |work|
        work.must_be_kind_of Work
      end
    end
  end

  describe "validations" do
    it "requires a username" do
      user = User.new
      user.valid?.must_equal false
      user.errors.messages.must_include :username
    end

    it "requires a unique username" do
      username = "test username"
      user1 = User.new(username: username)
      user1.uid = 9999
      user1.provider = "github"

      # This must go through, so we use create!
      user1.save!

      user2 = User.new(username: username)
      user2.uid = 111111
      user2.provider = "github"

      result = user2.save
      result.must_equal false
      user2.errors.messages.must_include :username
    end

  end

  describe "build from github" do
    it "returns a new user with valid info" do
      auth_hash = {
        "uid" => 1234,
        "info" => {
          "email" => "new_email@gmail.com",
          "nickname" => "new user"
        }
      }

      proc {
        User.build_from_github(auth_hash)
      }.must_change 'User.count', 1
    end

    it "does not create a new user if given invalid info" do
      auth_hash = {
        "uid" => nil,
        "info" => {
          "email" => "new_email@gmail.com",
          "nickname" => "new user"
        }
      }

      proc {
        User.build_from_github(auth_hash)
      }.must_change 'User.count', 0
    end
  end
end
