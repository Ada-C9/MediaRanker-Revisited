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
      Work.destroy_all

      Work.count.must_equal 0
      get root_path
      must_respond_with :success
    end
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do
    it "succeeds for OATH users when there are works" do
      perform_login(users(:ada))
      Work.count.must_equal 4
      get works_path

      must_respond_with :success
    end

    it "succeeds for users when there are works" do
      post login_path, params: {
        username: "dan"
      }
      Work.count.must_equal 4
      get works_path
      must_respond_with :success
    end

    it "succeeds for OATH users when there are no works" do
      perform_login(users(:ada))
      Work.destroy_all
      Work.count.must_equal 0
      get works_path

      must_respond_with :success
    end

    it "succeeds for users when there are no works" do
      post login_path, params: {
        username: "dan"
      }
      Work.destroy_all
      Work.count.must_equal 0
      get works_path

      must_respond_with :success
    end

    it "redirects to root_path if not logged in" do
      Work.count.must_equal 4
      get works_path
      must_redirect_to root_path
    end
  end

  describe "new" do
    it "succeeds for OATH users" do
      perform_login(users(:ada))
      get new_work_path

      must_respond_with :success
    end

    it "succeeds for logged in users" do
      post login_path, params: {
        username: "dan"}
      get new_work_path

      must_respond_with :success
    end

    it "redirects for no users" do
      get new_work_path
      must_redirect_to root_path
    end
  end

  describe "create" do
    it "creates a work with valid data for a real category - OATH" do
      proc {
        perform_login(users(:ada))

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

    it "creates a work with valid data for a real category - User" do
      proc {
        post login_path, params: {
          username: "dan"}

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

    it "renders bad_request; doesn't update the DB for bogus data - OATH" do
      proc {
        perform_login(users(:ada))

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

    it "renders bad_request; doesn't update the DB for bogus data - User" do
      proc {
        post login_path, params: {
          username: "dan"}

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

    it "renders 400 bad_request for bogus categories - OATH" do
      INVALID_CATEGORIES.each do |category|
        proc {
          perform_login(users(:ada))
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

    it "renders 400 bad_request for bogus categories - User" do
      INVALID_CATEGORIES.each do |category|
        proc {
          post login_path, params: {
            username: "dan"}
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

    it "redirects for no user" do
      proc {
        post works_path, params: {
          work: {
            title: "Book title",
            creator: "An author",
            category: "Book",
            publication_year: 1984
          }
        }
      }.must_change "Work.count", 0

      must_respond_with :redirect
      must_redirect_to root_path
    end
  end

  describe "show" do
    it "succeeds for an extant work ID - OATH" do
      perform_login(users(:ada))
      get work_path(works(:album).id)

      must_respond_with :success
    end

    it "succeeds for an extant work ID - User" do
      post login_path, params: {
        username: "dan"}
      get work_path(works(:album).id)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID - OATH" do
      perform_login(users(:ada))

      get work_path(Work.last.id+1)
      must_respond_with :not_found
    end

    it "renders 404 not_found for a bogus work ID -  User" do
      post login_path, params: {
        username: "dan"
      }

      get work_path(Work.last.id+1)
      must_respond_with :not_found
    end

    it "redirects when user not logged in" do
      get work_path(works(:album).id)
      must_redirect_to root_path
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID - OATH" do
      perform_login(users(:ada))
      get edit_work_path(works(:album).id)

      must_respond_with :success
    end

    it "succeeds for an extant work ID - User" do
      post login_path, params: {
        username: "dan"}
      get edit_work_path(works(:album).id)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID - OATH" do
      perform_login(users(:ada))
      get edit_work_path(Work.last.id+1)

      must_respond_with :not_found
    end

    it "logged in: renders 404 not_found for a bogus work ID - User" do
      post login_path, params: {
        username: "dan"}
      get edit_work_path(Work.last.id+1)

      must_respond_with :not_found
    end

    it "redirects for an extant work ID when no user" do
      get edit_work_path(works(:album).id)
      must_redirect_to root_path
    end

    it "redirects for a bogus work ID when no user" do
      get edit_work_path(Work.last.id+1)
      must_redirect_to root_path
    end
  end

  describe "update" do
    it "succeeds for valid data and an extant work ID - OATH" do
      perform_login(users(:ada))

      updated_title = "deeface"

      put work_path(works(:album).id), params: {
        work: {
          title: "deeface" }}

      updated_work = Work.find(works(:album).id)
      updated_work.title.must_equal updated_title
      must_redirect_to work_path(works(:album).id)
    end

    it "succeeds for valid data and an extant work ID - User" do
      post login_path, params: {
      username: "dan"}

      updated_title = "deeface"

      put work_path(works(:album).id), params: {
        work: {
          title: "deeface" }}

      updated_work = Work.find(works(:album).id)
      updated_work.title.must_equal updated_title
      must_redirect_to work_path(works(:album).id)
    end

    it "renders bad_request for bogus data - OATH" do
      perform_login(users(:ada))
      put work_path(works(:album).id), params: {
        album: {
          title: "" }}

      must_respond_with :bad_request
    end

    it "renders bad_request for bogus data - User" do
      post login_path, params: {
        username: "dan"}
      put work_path(works(:album).id), params: {
        album: {
          title: "" }}

      must_respond_with :bad_request
    end

    it "renders 404 not_found for a bogus work ID - OATH" do
      perform_login(users(:ada))

      put work_path(Work.last.id+1), params: {
        work: {
          title: "deeface" }}
      must_respond_with :not_found
    end

    it "renders 404 not_found for a bogus work ID - User" do
      post login_path, params: {
      username: "dan"}

      put work_path(Work.last.id+1), params: {
        work: {
          title: "deeface" }}
      must_respond_with :not_found
    end

    it "redirects when not logged in" do
      put work_path(works(:album).id), params: {
        work: {
          title: "deeface" }}

      must_redirect_to root_path
    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID - User" do
      Work.count.must_equal 4
      post login_path, params: {
      username: "dan"}
      delete work_path(works(:album).id)

      must_respond_with :redirect
      must_redirect_to root_path
      Work.count.must_equal 3
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      post login_path, params: {
      username: "dan"}
      delete work_path("carrot")

      must_respond_with :not_found
    end

    it "redirects if not logged in" do
      Work.count.must_equal 4
      delete work_path(works(:album).id)

      must_respond_with :redirect
      must_redirect_to root_path
      Work.count.must_equal 4
    end
  end

  describe "upvote" do
    it "redirects to the work page if no user is logged in" do
      Vote.count.must_equal 4
      post upvote_path(works(:album).id)

      must_respond_with :redirect
      must_redirect_to root_path
      Vote.count.must_equal 4
    end

    it "succeeds for a logged-in user and a fresh user-vote pair - OATH" do
      proc {
        perform_login(users(:ada))

        post upvote_path(works(:poodr).id), params: {
          user: users(:ada),
          work: works(:poodr)
        }
      }.must_change "Vote.count", 1

      must_respond_with :redirect
      must_redirect_to work_path(works(:poodr).id)
    end

    it "succeeds for a logged-in user and a fresh user-vote pair - User" do
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

    it "redirects to the work page if the user has already voted for that work - OATH" do
      proc {
        perform_login(users(:ada))

        post upvote_path(works(:album).id), params: {
          user: users(:ada),
          work: works(:album)
        }
      }.must_change "Vote.count", 0
      must_respond_with :redirect
      must_redirect_to work_path(works(:album).id)
    end

    it "redirects to the work page if the user has already voted for that work - User" do
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
