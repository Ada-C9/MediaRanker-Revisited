require 'test_helper'

describe User do
  describe "relations" do
    it "has a list of votes" do
      ada = users(:ada)
      ada.must_respond_to :votes
      ada.votes.each do |vote|
        vote.must_be_kind_of Vote
      end
    end

    it "has a list of ranked works" do
      dan = users(:ada)
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
      user.errors.messages.must_include :name
    end

    it "requires a unique username" do
      one = User.first
      two = User.last

      two.name = one.name
      two.save

      two.valid?.must_equal false
      two.errors.messages.must_include :name
    end
  end
end
