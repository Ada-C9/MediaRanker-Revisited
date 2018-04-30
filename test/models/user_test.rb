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
    it "requires an email" do
      user = User.new(uid: 99999, provider: 'github')
      user.valid?.must_equal false
      user.errors.messages.must_include :email
    end

    it "requires a unique uid" do
      user1 = User.new(uid: 12345, provider: 'github', email: 'fake@fake.com')

      # This must go through, so we use create!
      user1.save!

      user2 = User.new(uid: 12345, provider: 'github', email: 'fake2@fake.com')
      result = user2.save
      result.must_equal false
      user2.errors.messages.must_include :uid
    end

    it 'requires a provider' do
      user = User.new(uid: 99999, email: '29394@ghghgh.com')
      user.valid?.must_equal false
      user.errors.messages.must_include :provider
    end

  end
end
