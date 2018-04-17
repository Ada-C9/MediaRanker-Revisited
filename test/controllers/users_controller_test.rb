require 'test_helper'

describe UsersController do
  describe 'index' do
    it 'succeeds when there are users' do
      get users_path

      must_respond_with :success
    end
    it 'succeeds when there are no users' do
      User.all.each do |user|
        if !user.votes.empty?
          user.votes.each { |vote| vote.destroy }
        end
        user.destroy
      end

      get users_path

      must_respond_with :success
    end
  end
  describe 'show' do
    it 'succeeds for an extant work ID' do
      get user_path(users(:dan).id)

      must_respond_with :success
    end
    it 'renders 404 not_found for an invalid work ID' do
      id = users(:dan).id
      byebye = User.find_by(id: id)
      byebye.votes.each {|vote| vote.destroy }
      byebye.destroy

      get user_path(id)

      must_respond_with 404
    end
  end
end
