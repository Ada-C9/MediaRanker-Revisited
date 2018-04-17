require 'test_helper'

describe WorksController do
  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category
      Work.where(category: "album").count.must_be :>, 0
      Work.where(category: "book").count.must_be :>, 0
      Work.where(category: "movie").count.must_be :>, 0

      get root_path
      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      Work.where(category: "album").count.must_be :>, 0
      Work.where(category: "book").count.must_be :>, 0

      Work.where(category: "movie").destroy_all

      Work.where(category: "movie").count.must_equal 0
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
      Work.count.must_be :>, 0

      get works_path
      must_respond_with :success
    end

    it "succeeds when there are no works" do
      Work.destroy_all
      Work.where(category: "movie").count.must_equal 0

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
      work_data = {
        title: 'c test title',
        creator: 'c test creator',
        description: 'c test description',
        category: CATEGORIES[0],
        publication_year: 2018
      }
      original_count = Work.count

      work = Work.new(work_data)
      work.must_be :valid?

      post works_path, params: { work: work_data }

      must_respond_with :redirect
      must_redirect_to work_path(Work.last)
      Work.count.must_equal original_count + 1
      Work.last.title.must_equal 'c test title'
    end

    it "renders bad_request and does not update the DB for bogus data" do
      work_data = {
        title: '',
        creator: 'c test creator',
        description: 'c test description',
        category: CATEGORIES[0],
        publication_year: 2018
      }
      original_count = Work.count

      Work.new(work_data).wont_be :valid?

      post works_path, params: { work: work_data }

      must_respond_with :bad_request
      Work.count.must_equal original_count
    end

    it "renders 400 bad_request for bogus categories" do
      work_data = {
        title: 'c test title',
        creator: 'controller test creator',
        description: 'controller test description',
        category: INVALID_CATEGORIES[0],
        publication_year: 2018
      }
      original_count = Work.count

      Work.new(work_data).wont_be :valid?

      post works_path, params: { work: work_data }

      must_respond_with :bad_request
      Work.count.must_equal original_count
    end

  end

  describe "show" do
    it "succeeds for an extant work ID" do
      work_id = Work.first

      get work_path(work_id)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      work_id = Work.last.id + 1

      get work_path(work_id)
      must_respond_with :not_found
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do
      work_id = Work.first

      get edit_work_path(work_id)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      work_id = Work.last.id + 1

      get work_path(work_id)
      must_respond_with :not_found
    end
  end

  describe "update" do
    it "succeeds for valid data and an extant work ID" do
      work = works(:poodr)

      work_data = {
        title: 'c test title'
      }

      work.must_be :valid?

      patch work_path(work), params: { work: work_data }

      must_respond_with :redirect
      must_redirect_to work_path(work)

      work.reload
      work.title.must_equal 'c test title'
    end

    it "renders not_found for bogus data" do
      work = works(:poodr)

      work_data = {
        title: ''
      }

      work.must_be :valid?

      patch work_path(work), params: { work: work_data }

      must_respond_with :not_found
      work.reload
      work.title.wont_equal ''
    end

    it "renders 404 not_found for a bogus work ID" do
      work_id = Work.last.id + 1

      patch work_path(work_id)

      must_respond_with :not_found
    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do
      work = Work.first
      original_count = Work.count

      delete work_path(work.id)

      must_respond_with :redirect
      must_redirect_to root_path

      Work.count.must_equal original_count - 1
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      work_id = Work.last.id + 1
      original_count = Work.count

      delete work_path(work_id)

      must_respond_with :not_found

      Work.count.must_equal original_count
    end
  end

  describe "upvote" do

    it "redirects to the work page if no user is logged in" do
      post login_path, params: { username: nil }
      work = Work.first

      post upvote_path(work)

      must_respond_with :redirect
      must_redirect_to work_path(work)
    end

    it "redirects to the work page after the user has logged out" do
      username = users(:dan).username

      # login
      post login_path, params: { username: username }

      # logout
      post logout_path

      # vote
      work = Work.first
      post upvote_path(work)

      must_respond_with :redirect
      must_redirect_to work_path(work)
    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      username = users(:dan).username
      # login
      post login_path, params: { username: username }

      work = Work.first
      post upvote_path(work)

      must_respond_with :redirect
      must_redirect_to work_path(work)
    end

    it "redirects to the work page if the user has already voted for that work" do
      username = users(:dan).username
      # login
      post login_path, params: { username: username }

      # first vote
      work = Work.first
      post upvote_path(work)
      # attempted second vote
      post upvote_path(work)

      must_respond_with :redirect
      must_redirect_to work_path(work)
    end
  end
end
