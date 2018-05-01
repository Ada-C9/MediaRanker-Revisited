require 'test_helper'
require 'pry'

describe WorksController do
  let(:ada) { users(:ada) }
  let(:kari) { users(:kari) }

  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category
      get root_path
      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      work = works(:movie)
      work.delete

      get root_path
      must_respond_with :success
    end

    it "succeeds with no media" do
      works(:album).destroy
      works(:another_album).destroy
      works(:poodr).destroy
      works(:movie).destroy

      Work.all.count.must_equal 0
      get root_path
      must_respond_with :success
    end
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do
    it "succeeds when there are works" do
      perform_login(ada)
      get works_path
      must_respond_with :success
    end

    it "succeeds when there are no works" do
      works(:album).destroy
      works(:another_album).destroy
      works(:poodr).destroy
      works(:movie).destroy

      Work.all.count.must_equal 0
      perform_login(ada)
      get works_path
      must_respond_with :success
    end
  end

  describe "new" do
    it "succeeds" do
      perform_login(ada)
      get new_work_path
      must_respond_with :success
    end
  end

  describe "create" do
    it "creates a work with valid data for a real category" do
      perform_login(ada)
      proc {
        post works_path, params: {
          work: {
            category: "movie",
            title: "Superbad"
          }
        }
      }.must_change 'Work.count', 1

      flash[:status].must_equal :success
      must_respond_with :redirect
      must_redirect_to work_path(Work.last)
    end

    it "renders bad_request and does not update the DB for bogus data" do
      perform_login(ada)
      proc {
        post works_path, params: {
          work: {
            category: "album",
          }
        }
      }.must_change 'Work.count', 0
      must_respond_with :bad_request
    end

    it "renders 400 bad_request for bogus categories" do
      perform_login(ada)
      post works_path, params: {
        work: {
          category: "play",
          title: "Hamlet"
        }
      }
      must_respond_with :bad_request
    end
  end

  describe "show" do
    it "succeeds for an extant work ID" do
      perform_login(ada)
      session[:user_id].must_equal ada.id
      get work_path(works(:poodr).id)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      works(:album).id = 'testid'
      get work_path(works(:album).id)
      must_respond_with :not_found
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do
      perform_login(ada)
      get edit_work_path(works(:movie).id)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      works(:poodr).id = 239847
      get edit_work_path(works(:poodr).id)
      must_respond_with :not_found
    end
  end

  describe "update" do
    it "succeeds for valid data and an extant work ID" do
      perform_login(ada)
      put work_path works(:album).id, params: {
        work: {
          category: "album",
          title: "Newer Title",
          creator: "You Create"
        }
      }

      updated_work = Work.find(works(:album).id)

      updated_work.title.must_equal "Newer Title"
      must_respond_with :redirect
    end

    it "renders not_found for bogus data" do
      perform_login(ada)
      put work_path works(:another_album).id, params: {
        work: {
          category: "play",
        }
      }

      updated_work = Work.find(works(:another_album).id)

      must_respond_with :not_found
    end

    it "renders 404 not_found for a bogus work ID" do
      works(:poodr).id = 239847
      put work_path(works(:poodr).id)
      must_respond_with :not_found
    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do
      perform_login(ada)
      proc {
        delete work_path(works(:movie).id)
      }.must_change 'Work.count', -1

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      proc {
        delete work_path("nope")
      }.must_change 'Work.count', 0

      must_respond_with :not_found
    end
  end

  describe "upvote" do

    it "redirects to the works page if no user is logged in" do
      post upvote_path(works(:poodr).id)
      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "redirects to the work page after the user has logged out" do
      delete logout_path
      must_redirect_to root_path
    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      kari = users(:kari)
      perform_login(kari)

      work = Work.find_by(id: works(:movie).id)

      proc {
        post upvote_path(work.id), params: {
          vote: { user: kari, work: work }
        }
      }.must_change 'Vote.count', 1

      must_respond_with :redirect
      must_redirect_to work_path(works(:movie))
    end

    it "redirects to the work page if the user has already voted for that work" do
      perform_login(kari)
      before_count = Vote.count
      work = Work.find_by(id: works(:movie).id)

      post upvote_path(work.id)
      post upvote_path(work.id)

      Vote.count.must_equal (before_count + 1)
      must_respond_with :redirect
      must_redirect_to work_path(works(:movie))
    end
  end
end
