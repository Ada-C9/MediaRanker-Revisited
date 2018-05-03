require 'test_helper'
require "pry"

describe WorksController do
  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category

    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories

    end

    it "succeeds with no media" do

    end
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do
    it "succeeds when there are works" do

      Work.count.must_be :>,0

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
      work_data = {title: "Hola me llamo Wini", category: "album"}
      Work.new(work_data).must_be :valid?

      old_count = Work.all.count
      post works_path, params: {work: work_data}

      must_respond_with :redirect
      must_redirect_to work_path(Work.last.id)


      Work.all.count.must_equal old_count + 1


    end

    it "renders bad_request and does not update the DB for bogus data" do
      work_data = {category: "album"}

      Work.new(work_data).wont_be :valid?


      old_count = Work.all.count
      post works_path, params: {work: work_data}

      must_respond_with :bad_request

      Work.all.count.must_equal old_count

    end

    it "renders 400 bad_request for bogus categories" do

      work_data = {title: "My name is wini", category: "bird"}

      Work.new(work_data).wont_be :valid?


      old_count = Work.all.count
      post works_path, params: {work: work_data}

      must_respond_with :bad_request

      Work.all.count.must_equal old_count

    end

  end

  describe "show" do
    it "succeeds for an extant work ID" do

      work = Work.first

      get work_path(work.id)

      must_respond_with :success

    end

    it "renders 404 not_found for a bogus work ID" do
      skip
      get work_path(Work.last.id + 1)

      must_respond_with :not_found

    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do

      work = Work.first

      get edit_work_path(work.id)

      must_respond_with :success



    end

    it "renders 404 not_found for a bogus work ID" do

      work = Work.first

      get edit_work_path(work.id + 1)

      must_respond_with :not_found

    end
  end

  describe "update" do
    it "succeeds for valid data and an extant work ID" do

      work = Work.first

      work_data = {title: "My name is Wini"}

      patch work_path(work.id), params: {work: work_data}

      must_respond_with :redirect
      must_redirect_to work_path(Work.first.id)
      Work.first.title.must_equal "My name is Wini"

    end

    it "renders bad_request for bogus data" do

      work = Work.first

      work_data = {title: nil}

      patch work_path(work.id), params: {work: work_data}

      must_respond_with :bad_request

    end

    it "renders 404 not_found for a bogus work ID" do
      work_id = Work.first.id + 1

      work_data = {title: "My name is Wini"}

      patch work_path(work_id), params: {work: work_data}

      must_respond_with :not_found

    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do
      work = Work.first
      old_count = Work.count

      delete work_path(work.id)

      must_respond_with :redirect
      Work.count.must_equal old_count -1

    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do

      work = Work.first
      old_count = Work.count

      delete work_path(work.id + 1)

      must_respond_with :not_found
      Work.count.must_equal old_count
    end
  end

  describe "upvote" do

    it "redirects to the work page if no user is logged in" do
      skip

      work = Work.first
      count = work.votes.count

      post upvote_path(work.id)

      must_respond_with :redirect
      must_redirect_to work_path(work.id)
      Work.first.votes.count.must_equal count

    end

    it "redirects to the work page after the user has logged out" do
      skip
      work = Work.first
      count = work.votes.count
      user = User.first

      get login_path, params: {user: {username: user.username}}

      post logout_path, params: {user: {username: user.username}}


      post upvote_path(work.id)

      must_respond_with :redirect
      must_redirect_to work_path(work.id)

      Work.first.votes.count.must_equal count

    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      skip
      work = Work.first
      count = work.votes.count
      user = User.first

      get login_path, params: {user: {username: user.username}}

      post upvote_path(work.id)
      must_respond_with :redirect
      must_redirect_to work_path(work.id)
      Work.first.votes.count.must_equal count + 1

    end

    it "redirects to the work page if the user has already voted for that work" do

    end
  end
end
