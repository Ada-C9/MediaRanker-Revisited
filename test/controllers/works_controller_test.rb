require 'test_helper'
require 'pry'

describe WorksController do
  describe 'logged in user' do

    before do

    end
    it "text" do

    end

  end

  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category
      get root_path

      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      movies = Work.where(category: 'movie')
      movies.destroy_all

      get root_path
      must_respond_with :success
    end

    it "succeeds with no media" do
      Work.destroy_all

      get root_path

      must_respond_with :success
    end
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do
    it "succeeds when there are works" do
      get works_path

      must_respond_with :success
    end

    it "succeeds when there are no works" do
      Work.destroy_all

      get works_path

      must_respond_with :success
    end
  end

  describe "new" do
    it "succeeds" do
      get new_work_path

      must_respond_with :success
    end
  end

  describe "create" do
    it "creates a work with valid data for a real category" do
      # Arrange
      work_data = {
        title: 'controller test book',
        category: 'book'
      }

      old_count = Work.count

      # Assumptions
      Work.new(work_data).must_be :valid?

      # Act
      post works_path, params: { work: work_data}

      # Assert
      must_respond_with :redirect
      must_redirect_to work_path(Work.last.id)
      Work.count.must_equal old_count + 1
      Work.last.title.must_equal work_data[:title]
    end

    it "renders bad_request and does not update the DB for bogus data" do
      # Arrange
      work_data = {
        category: 'movie'
      }
      old_count = Work.count
      # Assumptions
      Work.new(work_data).wont_be :valid?
      # Act
      post works_path, params: { work: work_data}
      # Assert
      must_respond_with :bad_request
      Work.count.must_equal old_count
    end

    it "renders 400 bad_request for bogus categories" do
      # Arrange
      work_data = {
        category: 'mosaic'
      }
      old_count = Work.count
      # Assumptions
      Work.new(work_data).wont_be :valid?
      # Act
      post works_path, params: { work: work_data}
      # Assert
      must_respond_with :bad_request
      Work.count.must_equal old_count
    end

  end

  describe "show" do
    it "succeeds for an extant work ID" do
      get work_path(Work.first)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      work_id = Work.last.id + 1

      get work_path(work_id)

      must_respond_with 404
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do
      get edit_work_path(Work.first)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      work_id = Work.last.id + 1

      get edit_work_path(work_id)

      must_respond_with 404

    end
  end

  describe "update" do
    it "succeeds for valid data and an extant work ID" do
      work = Work.first
      work_data = work.attributes
      work_data[:title] = "some updated title"

      work.assign_attributes(work_data)
      work.must_be :valid?

      patch work_path(work), params: { work: work_data}

      must_redirect_to work_path(work)
      work.reload
      work.title.must_equal work_data[:title]
    end

    it "renders 404 not_found for bogus data" do
      work = Work.first
      work_data = work.attributes
      work_data[:title] = ""

      work.assign_attributes(work_data)
      work.wont_be :valid?

      patch work_path(work), params: { work: work_data}

      must_respond_with :not_found
      work.reload
      work.title.wont_equal work_data[:title]
    end

    it "renders 404 not_found for a bogus work ID" do
      work_id = Work.last.id + 1

      patch work_path(work_id)

      must_respond_with :not_found

    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do
      work_id = Work.first.id
      count = Work.count

      delete work_path(work_id)

      Work.count.must_equal count - 1
      Work.find_by(id: work_id).must_be_nil
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      work_id = Work.first.id + 1
      count = Work.count

      delete work_path(work_id)

      must_respond_with 404
      Work.count.must_equal count
    end
  end

  describe "upvote" do
    it "redirects to the work page if no user is logged in" do
      work_id = Work.first.id
      vote_count = Work.first.votes.count

      post upvote_path(work_id)

      vote_count.must_equal vote_count
      must_redirect_to work_path(work_id)
    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      user = User.last
      post login_path, params: { username: user.username}
      work = Work.first
      old_vote_count = work.votes.count

      post upvote_path(work.id)

      work.votes.count.must_equal old_vote_count + 1
      must_redirect_to work_path(work.id)
    end

    it "redirects to the work page if the user has already voted for that work" do
      user = User.first
      post login_path, params: { username: user.username}
      work = Work.first
      old_vote_count = Work.first.votes.count

      post upvote_path(work.id)
      post upvote_path(work.id)

      work.vote_count.wont_equal old_vote_count + 1
      must_redirect_to work_path(work.id)
    end
  end

  describe 'guest user' do
    it "rejects requests to upvote a work" do

    end
    it "rejects requests for new work form" do
      get new_work_path
      must_respond_with :unauthorized
    end

    it "rejects requests to create a work" do
      work_data = {
        title: 'controller test book',
        category: 'book'
      }
      old_work_count = Work.count

      Work.new(work_data).must_be :valid?

      post works_path, params: { work: work_data }

      must_respond_with :unauthorized
      Work.count.must_equal old_work_count

    end
    it "rejects requests to edit a work" do

    end
    it "rejects requests to update a work" do

    end
    it "rejects requests to delete a work" do

    end
  end
end
