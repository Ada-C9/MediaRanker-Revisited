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
      work = works(:movie)
      work.destroy
      # Work.find(works(:movie).id).destroy

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
        post works_path, params:{
          work: {
            category: "movie",
            title: "We're Back",
            creator: "some dude"
          }
        }
      }.must_change 'Work.count', 1

      work = Work.find_by(title: "We're Back").id

      must_respond_with :redirect
      must_redirect_to work_path(work)
    end

    it "renders bad_request and does not update the DB for bogus data" do
      proc {
        post works_path, params:{
          work: {
            category: "movie"
          }
        }
      }.must_change 'Work.count', 0
      post works_path
      must_respond_with :bad_request
    end

    it "renders 400 bad_request for bogus categories" do
      proc {
        post works_path, params:{
          work: {
            category: "nope",
            title: "We're Back",
            creator: "some dude"
          }
        }
      }
      post works_path
      must_respond_with :bad_request
    end

  end
  #
  describe "show" do
    it "succeeds for an extant work ID" do
      get work_path(works(:movie))
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      works(:movie).id = 'smelly_cat'
      get work_path(works(:movie).id)
      must_respond_with :not_found
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do
      get edit_work_path(works(:movie).id)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      works(:movie).id = 'smelly_cat'
      get edit_work_path(works(:movie).id)
      must_respond_with :not_found
    end
  end

  describe "update" do
    it "succeeds for valid data and an extant work ID" do
      put work_path (works(:movie)), params: {
        work: {
          category: 'movie',
          title: 'Harold & Maude'
        }
      }

      updated_work = Work.find(works(:movie).id)

      updated_work.title.must_equal 'Harold & Maude'
      must_respond_with :redirect
    end

    it "renders bad_request for bogus data" do
      put work_path (works(:movie)), params: {
        work: {
          category: 'nope',
          title: ''
        }
      }

      must_respond_with :not_found
    end

    it "renders 404 not_found for a bogus work ID" do
      works(:movie).id = 'smelly_cat'
      put work_path(works(:movie).id)
      must_respond_with :not_found
    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do
      proc {delete work_path(works(:movie).id) }.must_change 'Work.count', -1

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      works(:movie).id = 'smelly_cat'
      delete work_path(works(:movie).id)
      must_respond_with :not_found
    end
  end

  describe "upvote" do

    it "redirects to the work page if no user is logged in" do

      post upvote_path(works(:movie).id)
      must_redirect_to work_path(works(:movie).id)
    end

    it "***** redirects to the work page after the user has logged out" do
      post logout_path
      must_redirect_to root_path
    end

    # it "succeeds for a logged-in user and a fresh user-vote pair" do
    #
    #   proc {
    #     post github_login_path params: {
    #       username: users(:kari).username
    #     }
    #     voted_on_work = Work.find_by(id: works(:movie).id)
    #     post upvote_path(voted_on_work.id), params: {
    #       vote: { user: users(:kari), work: voted_on_work }
    #     }
    #   }.must_change 'Vote.count', 1
    #
    #   must_respond_with :redirect
    #   must_redirect_to work_path(works(:movie))
    #
    # end

    # it "redirects to the work page if the user has already voted for that work" do
    #
    #   proc {
    #     post github_login_path params: {
    #       username: users(:kari).username
    #     }
    #     voted_on_work = Work.find_by(id: works(:movie).id)
    #     post upvote_path(voted_on_work.id), params: {
    #       vote: { user: users(:kari), work: voted_on_work }
    #     }
    #     post upvote_path(voted_on_work.id), params: {
    #       vote: { user: users(:kari), work: voted_on_work }
    #     }
    #   }.must_change 'Vote.count', 1
    #
    #   must_respond_with :redirect
    #   must_redirect_to work_path(works(:movie))
    # end
  end
end
