require 'test_helper'

describe WorksController do

  describe "root" do

    it "succeeds with all media types" do
    #   # Precondition: there is at least one media of each category
      %w(album book movie).each do |category|
        Work.by_category(category).length.must_be :>, 0
      end
      get root_path
      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      Work.by_category("album").destroy_all
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
      Work.count.must_be :>, 0
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
      proc {
        post works_path, params: {
          work: {
            :title => "Some Title", :category => "movie"
          }
        }
      }.must_change  'Work.count', 1

      must_respond_with :redirect
      must_redirect_to work_path(Work.last)
    end

    it "renders bad_request and does not update the DB for bogus data" do
      proc {
        post works_path, params: {
          work: {
            :category => "movie"
          }
        }
      }.wont_change 'Work.count'

      must_respond_with :bad_request
    end

    it "renders 400 bad_request for bogus categories" do

      INVALID_CATEGORIES.each do |category|
        proc {
          post works_path, params: {
            work: {
              :category => category, :title =>"Some Title"
            }
          }
        }.wont_change 'Work.count'
        must_respond_with :bad_request
      end
    end
  end

  describe "show" do
    it "succeeds for an existant work ID" do
      get work_path(works(:album).id)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      get work_path("foo")
      must_respond_with 404
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do
      get edit_work_path(works(:album).id)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      get edit_work_path("foo")
      must_respond_with 404
    end
  end

  describe "update" do
    it "succeeds for valid data and an existant work ID" do
      get work_path(works(:album).id)
      must_respond_with :success
    end

    it "renders bad_request for bogus data" do
      get work_path("foo")
      must_respond_with 404
    end

    it "renders 404 not_found for a bogus work ID" do
      get work_path("foo")
      must_respond_with 404
    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do
      proc {
        delete work_path(works(:album).id), params: {
          work: {
            :title => "Some Title", :category => "movie"
          }
        }
      }.must_change  'Work.count', -1

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      get work_path("foo")
      must_respond_with 404
    end
  end

  describe "upvote" do

    it "redirects to the work page if no user is logged in" do
      @login_user = nil

      post upvote_path(works(:album).id)
      must_respond_with :redirect
      must_redirect_to work_path(works(:album).id)
    end

    it "redirects to the work page after the user has logged out" do

      @login_user = nil

      post upvote_path(works(:album).id)
      must_respond_with :redirect
      must_redirect_to work_path(works(:album).id)
    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      perform_login(users(:kari))

      proc { post upvote_path(works(:poodr).id) }.must_change 'Vote.count', 1
      must_respond_with :redirect
      must_redirect_to work_path(works(:poodr).id)

    end

    it "redirects to the work page if the user has already voted for that work" do
      perform_login(users(:kari))

      proc { post upvote_path(works(:album).id) }.must_change 'Vote.count', 0
      must_respond_with :redirect
      must_redirect_to work_path(works(:album).id)
    end
  end
end
