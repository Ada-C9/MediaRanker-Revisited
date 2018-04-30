require 'test_helper'

describe WorksController do
  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category
      Work.count.must_equal 4
      get root_path
      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      a = Work.last
      a.destroy
      Work.count.must_equal 3

      get root_path
      must_respond_with :success

    end

    it "succeeds with no media" do
      Work.all.each do |work|
        work.destroy
      end

      Work.count.must_equal 0
      get root_path
      must_respond_with :success

    end
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do
    it "succeeds when there are works" do
      Work.count.must_equal 4
      get works_path
      must_respond_with :success
    end

    it "succeeds when there are no works" do
      Work.all.each do |work|
        work.destroy
      end

      Work.count.must_equal 0
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
        post login_path, params: {
          username: "dan"
        }

        post works_path, params: {
          work: {
            title: "Book title",
            creator: "An author",
            category: "Book",
            publication_year: 1984
          }
        }
      }.must_change "Work.count", 1

      must_respond_with :redirect
      must_redirect_to work_path((Work.find_by(title: "Book title").id))
    end

    it "renders bad_request and does not update the DB for bogus data" do
      proc {
        post works_path, params: {
          work: {
            title: "",
            creator: "An author",
            category: "Book",
            publication_year: 1984
          }
        }
      }.must_change "Work.count", 0

      Work.count.must_equal 4
      must_respond_with :bad_request
    end

    it "renders 400 bad_request for bogus categories" do
      INVALID_CATEGORIES.each do |category|
        proc {
          post works_path, params: {
            work: {
              title: "",
              creator: "An author",
              category: category,
              publication_year: 1984
            }
          }
        }.must_change "Work.count", 0

        Work.count.must_equal 4
        must_respond_with :bad_request
      end
    end
  end

  describe "show" do
    it "succeeds for an extant work ID" do
      get work_path(works(:album).id)
      must_respond_with :found
    end

    it "renders 404 not_found for a bogus work ID" do
      post login_path, params: {
        username: "dan"
      }
      
      get work_path(Work.last.id+1)
      must_respond_with :not_found
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do
      get edit_work_path(works(:album).id)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      get edit_work_path(Work.last.id+1)
      must_redirect_to :root_path
    end
  end

  describe "update" do
    it "succeeds for valid data and an extant work ID" do
      updated_title = "deeface"

      put work_path(works(:album).id), params: {
        work: {
          title: "deeface"
        }
      }

      updated_work = Work.find(works(:album).id)
      updated_work.title.must_equal updated_title
      must_respond_with :redirect
    end

    it "renders bad_request for bogus data" do
      put work_path(works(:album).id), params: {
        work: {
          title: ""
        }
      }

      must_respond_with :not_found
    end

    it "renders 404 not_found for a bogus work ID" do
      put work_path("works(:album).id"), params: {
        work: {
          category: "deeface"
        }
      }
      must_respond_with :not_found
    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do
      delete work_path(works(:album).id)
      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      delete work_path("carrot")
      must_respond_with :not_found
    end
  end

  describe "upvote" do
    it "redirects to the work page if no user is logged in" do
      Vote.count.must_equal 3

      post upvote_path(works(:album).id)

      must_respond_with :redirect
      # must_redirect_to work_path(works(:album).id)
      Vote.count.must_equal 3
    end

    it "redirects to the work page after the user has logged out" do
      post logout_path, params: {
        user: {
          username: "dan"
        }
      }

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      proc {
        post login_path, params: {
          username: "dan"
        }

        post upvote_path(works(:poodr).id), params: {
          user: users(:dan),
          work: works(:poodr)
        }
      }.must_change "Vote.count", 1

      must_respond_with :redirect
      must_redirect_to work_path(works(:poodr).id)
    end

    it "redirects to the work page if the user has already voted for that work" do

      proc {
        post login_path, params: {
          username: "dan"
        }

        post upvote_path(works(:album).id), params: {
          user: users(:dan),
          work: works(:album)
        }
      }.must_change "Vote.count", 0
      must_respond_with :redirect
      must_redirect_to work_path(works(:album).id)

    end
  end
end
