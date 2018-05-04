require 'test_helper'

describe WorksController do
  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category

      # Assumptions
      Work.where(category: "book").count.must_be :>, 0
      Work.where(category: "movie").count.must_be :>, 0
      Work.where(category: "album").count.must_be :>, 0

      get root_path

      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      Work.where(category: "book").destroy_all
      # Assumptions
      Work.where(category: "book").count.must_equal 0
      Work.where(category: "movie").count.must_be :>, 0
      Work.where(category: "album").count.must_be :>, 0

      get root_path

      must_respond_with :success
    end

    it "succeeds with no media" do
      Work.destroy_all
      # Assumptions
      Work.where(category: "book").count.must_equal 0
      Work.where(category: "movie").count.must_equal 0
      Work.where(category: "album").count.must_equal 0

      get root_path

      must_respond_with :success
    end
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do
    it "succeeds when there are works" do
      # Assumptions
      Work.count.must_be :>, 0

      get works_path
      must_respond_with :success
    end

    it "succeeds when there are no works" do
      Work.destroy_all

      # Assumptions
      Work.all.count.must_equal 0

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
        title: "test title",
        category: CATEGORIES.sample
      }
      old_count = Work.count

      post works_path, params: { work: work_data }

      must_respond_with :redirect
      Work.count.must_equal old_count + 1
    end

    it "renders bad_request and does not update the DB for bogus data" do
      work_data = {
        title: "",
        category: CATEGORIES.sample
      }
      old_count = Work.count
      work = Work.new(work_data)
      work.valid?.must_equal false

      post works_path, params: { work: work_data }

      must_respond_with :bad_request
      Work.count.must_equal old_count
    end

    it "renders 400 bad_request for bogus categories" do
      work_data = {
        title: "testing bad request",
        category: INVALID_CATEGORIES.sample
      }
      old_count = Work.count
      work = Work.new(work_data)
      work.valid?.must_equal false

      post works_path, params: { work: work_data }

      must_respond_with :bad_request
      Work.count.must_equal old_count
    end

  end

  describe "show" do
    it "succeeds for an extant work ID" do
      work_id = Work.first.id

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
      work_id = Work.first.id

      get edit_work_path(work_id)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      work_id = Work.last.id + 1

      get edit_work_path(work_id)

      must_respond_with :not_found
    end
  end

  describe "update" do
    it "succeeds for valid data and an extant work ID" do
      work = Work.first.id
      work_data = {
        title: "testing update",
        category: CATEGORIES.sample
      }

      patch work_path(work), params: {work: work_data}
      must_respond_with :redirect
      must_redirect_to work_path(work)
    end

    it "renders bad_request for bogus data" do
      work = Work.first.id
      work_data = {
        title: "testing update",
        category: INVALID_CATEGORIES.sample
      }

      patch work_path(work), params: {work: work_data}
      must_respond_with :bad_request
    end

    it "renders 404 not_found for a bogus work ID" do
      work = Work.last.id + 1
      work_data = {
        title: "testing update",
        category: CATEGORIES.sample
      }

      patch work_path(work), params: {work: work_data}
      must_respond_with :not_found
    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do
      work_id = Work.first.id
      old_count = Work.count

      delete work_path(work_id)

      must_respond_with :redirect
      must_redirect_to root_path
      Work.count.must_equal old_count - 1
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      work_id = Work.last.id + 1
      old_count = Work.count

      delete work_path(work_id)

      must_respond_with :not_found
      Work.count.must_equal old_count
    end
  end

  describe "upvote" do

    it "redirects to the work page if no user is logged in" do
      work = Work.first
      post upvote_path(work)
      must_respond_with :redirect
      must_redirect_to work_path(work)
    end

    it "redirects to the work page after the user has logged out" do
      work = Work.first
      user = User.first
      post login_path, params: {username: user.username}

      post upvote_path(work)
      must_respond_with :redirect
      must_redirect_to work_path(work)
    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      work = Work.first
      user = User.first
      Vote.destroy_all

      login(user)
      
      post upvote_path(work)
      flash[:status].must_equal :success
      must_redirect_to work_path(work)
    end

    it "redirects to the work page if the user has already voted for that work" do
      work = Work.first
      user = User.first
      Vote.create!(work: work, user: user)
      post login_path, params: {username: user.username}

      post upvote_path(work)
      must_respond_with :redirect
      must_redirect_to work_path(work)
    end
  end
end
