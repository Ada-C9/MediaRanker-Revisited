require 'test_helper'

describe WorksController do
  let(:album) { works(:album) }

  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category
      get root_path
      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      proc {
        album.destroy
      }.must_change 'Work.count', -1
      get root_path
      must_respond_with :success
    end

    it "succeeds with no media" do
      Work.destroy_all
      assert Work.all.empty?
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
      assert Work.all.empty?
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
            title: "New Work",
            category:  "album"
          }
        }
      }.must_change 'Work.count', 1

      # Assert
      must_respond_with :redirect
      must_redirect_to work_path(Work.last.id)


    end

    it "renders not_found and does not update the DB for bogus data" do
      proc {
        post works_path, params: {
          work: {
            title: "New work"
            # missing category
          }
        }
      }.must_change 'Work.count', 0

      must_respond_with :error
    end

    it "renders 400 bad_request for bogus categories" do
      proc {
        post works_path, params: {
          work: {
            title: "New work",
            category:  "wrong category"
          }
        }
      }.must_change 'Work.count', 0

      must_respond_with 400
    end

  end

  describe "show" do
    it "succeeds for an extant work ID" do
      get work_path(works(:album).id)

      must_respond_with :success

    end

    it "renders 404 not_found for a bogus work ID" do
      get work_path("wrong id")

      must_respond_with :missing
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do
      get edit_work_path(works(:album).id)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      get edit_work_path("wrong id")

      must_respond_with :missing # 404
    end
  end

  describe "update" do
    it "succeeds for valid data and an extant work ID" do

      patch work_path(works(:album).id), params: {
        work: {
          title: "Update title"
        }
      }

      must_respond_with :redirect
      must_redirect_to work_path(works(:album).id)
    end

    it "renders bad_request for bogus data" do

      patch work_path(works(:album).id), params: {
        work: {
          doesnt_exists: "Update title"
        }
      }

      must_respond_with :redirect
    end

    it "renders 404 not_found for a bogus work ID" do
      patch work_path("wrong id")

      must_respond_with :missing # 404
    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do
      proc {
        delete work_path(works(:album).id)
      }.must_change 'Work.count', -1

      must_respond_with :redirect
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      proc {
        delete work_path('bad id')
      }.must_change 'Work.count', 0

      must_respond_with 404
    end
  end

  describe "upvote" do

    it "redirects to the work page if no user is logged in" do
      post upvote_path(works(:album).id)

      must_respond_with :redirect
      must_redirect_to work_path(works(:album).id)
    end

    it "redirects to the work page after the user has logged out" do
      post login_path
      post logout_path
      # ? is this the right way to do this?

      post upvote_path(works(:album).id)

      must_respond_with :redirect
      must_redirect_to work_path(works(:album).id)
    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      post login_path
      # ? is this the right way to do this?

      post upvote_path(works(:album).id)

      must_respond_with :redirect
      must_redirect_to work_path(works(:album).id)
    end

    it "redirects to the work page if the user has already voted for that work" do
      post login_path
      # ? is this the right way to do this?

      post upvote_path(works(:album).id)
      post upvote_path(works(:album).id)
      
      must_respond_with :redirect
      must_redirect_to work_path(works(:album).id)
    end
  end
end
