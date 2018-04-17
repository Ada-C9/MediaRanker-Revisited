require 'test_helper'

describe WorksController do
  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category

      # given
        # fixtures
      # when
      get root_path
      # then
      must_respond_with :success

    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      # given
      # finds movie in fixtures and deletes it
      movie = Work.find(works(:movie).id)
      movie.delete
      # when
      get root_path
      # then
      must_respond_with :success

    end

    it "succeeds with no media" do
      works = Work.all
      works.destroy_all

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
      works = Work.all
      works.destroy_all

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
      proc   {
        post works_path, params: { work: {title: "Some new work", category: "movies"} }
      }.must_change 'Work.count', 1

      work = Work.find_by(title: "Some new work")

      must_respond_with :redirect
      must_redirect_to work_path(work.id)
    end

    it "renders bad_request and does not update the DB for bogus data" do
      proc   {
        post works_path, params: { work: {title: "Some new work", category: INVALID_CATEGORIES.first } }
      }.must_change 'Work.count', 0

      must_respond_with :bad_request
    end

    it "renders 400 bad_request for bogus categories" do

    end

  end

  describe "show" do
    it "succeeds for an extant work ID" do
      get work_path works(:movie).id

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      get work_path 999

      must_respond_with :missing
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do
      get edit_work_path(works(:album).id)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      put work_path 999

      must_respond_with :missing
    end
  end

  describe "update" do
    it "succeeds for valid data and an extant work ID" do

    end

    it "renders bad_request for bogus data" do

    end

    it "renders 404 not_found for a bogus work ID" do

    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do

    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do

    end
  end

  describe "upvote" do

    it "redirects to the work page if no user is logged in" do

    end

    it "redirects to the work page after the user has logged out" do

    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do

    end

    it "redirects to the work page if the user has already voted for that work" do

    end
  end
end
