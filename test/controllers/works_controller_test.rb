require 'test_helper'

describe WorksController do
  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category
      get root_path

      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      Work.all.where(category: "album").each do |work|
        work.destroy
      end

      get root_path

      Work.all.count.wont_equal 0
      Work.all.where(category: "album").count.must_equal 0
      must_respond_with :success
    end

    it "succeeds with no media" do
      Work.all.each do |work|
        work.destroy
      end

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
      Work.all.each do |work|
        work.destroy
      end

      get works_path

      Work.all.count.must_equal 0
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
            title: "New work",
            category: "album"
          }
        }
      }.must_change 'Work.count', 1

      must_respond_with :redirect
      must_redirect_to work_path(Work.find_by(title: "New work"))
    end

    it "renders bad_request and does not update the DB for bogus data" do
      proc {
        post works_path, params: {
          work: {
            title: "New work"
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
            category: "foo"
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
      get work_path("foo")

      must_respond_with :missing
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do
      get edit_work_path(works(:album).id)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      get edit_work_path("foo")

      must_respond_with :missing
    end
  end

  describe "update" do
    it "succeeds for valid data and an extant work ID" do
      updated_title = "Some Title"

      put work_path(works(:album).id), params: {
        work: {
          title: updated_title
        }
      }

      updated_work = Work.find(works(:album).id)
      updated_work.title.must_equal updated_title
      must_respond_with :redirect
      must_redirect_to work_path(works(:album).id)
    end

    it "renders 404 not_found for bogus data" do
      put work_path(works(:album).id), params: {
        foo: "foo"
        }

      # TODO: double check
      must_respond_with 400
    end

    it "renders 404 not_found for a bogus work ID" do
      put work_path("foo")

      must_respond_with 404
    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do
      proc {
        delete work_path(works(:album).id)
      }.must_change 'Work.count', -1

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      proc {
        delete work_path("foo")
      }.must_change 'Work.count', 0

      must_respond_with 404
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
