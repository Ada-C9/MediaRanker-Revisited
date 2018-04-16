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
      work = Work.find(works(:movie).id)
      work.destroy
      get root_path
      must_respond_with :success
    end


    it "succeeds with no media" do
      works = Work.all
      works.each do |work|
        work.votes.destroy
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
      works = Work.all
      works.each do |work|
        work.votes.destroy
        work.destroy
      end
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
            title: 'Harry Potter',
            creator: 'Wizards',
            description: 'magic',
            publication_year: 1955,
            category: :book
          }
        }
      }.must_change 'Work.count', 1

      must_respond_with :redirect
      must_redirect_to work_path(Work.find_by(title: 'Harry Potter').id)
    end

    it "renders bad_request and does not update the DB for bogus data" do
      proc {
        post works_path, params: {
          work: {
            creator: 'Wizards',
            description: 'magic',
            publication_year: 1955,
            category: :book
          }
        }
      }.must_change 'Work.count', 0

        must_respond_with :bad_request
    end

    it "renders 400 bad_request for bogus categories" do
      proc {
        post works_path, params: {
          work: {
            title: 'Harry Potter',
            creator: 'Wizards',
            description: 'magic',
            publication_year: 1955,
            category: "nope"
          }
        }
      }.must_change 'Work.count', 0

        must_respond_with :bad_request
    end

  end

  describe "show" do
    it "succeeds for an extant work ID" do
      get work_path(Work.find(works(:movie).id))
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      get work_path(789)
      must_respond_with 404
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do
      get edit_work_path(Work.find(works(:movie).id))
      must_respond_with :success

    end

    it "renders 404 not_found for a bogus work ID" do
      get edit_work_path(789)
      must_respond_with 404
    end
  end

  describe "update" do
    it "succeeds for valid data and an extant work ID" do
      updated_title = "The best title"

      put work_path(works(:movie).id), params: {
        work: {
          title: updated_title,
          category: :movie
        }
      }

      updated_work = Work.find(works(:movie).id)
      updated_work.title.must_equal "The best title"
      must_respond_with :redirect
      must_redirect_to work_path(Work.find(works(:movie).id))
    end

    it "renders bad_request for bogus data" do


      put work_path(works(:movie).id), params: {
        work: {
          category: "beans"
        }
      }

      must_respond_with 404

    end

    it "renders 404 not_found for a bogus work ID" do
      put work_path(789)
      must_respond_with 404

    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do
      delete work_path(Work.find(works(:movie).id))
      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      delete work_path(789)
      must_respond_with 404
    end
  end

  describe "upvote" do

    it "redirects to the work page if no user is logged in" do
      post upvote_path(Work.find(works(:movie).id))
      must_respond_with :redirect
      must_redirect_to work_path(Work.find(works(:movie).id))
    end

    it "redirects to the work page after the user has logged out" do
    skip
    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      get login_path
      Vote.count.must_equal 3
      post upvote_path(Work.find(works(:movie).id))
      must_respond_with :redirect
      must_redirect_to work_path(Work.find(works(:movie).id))

    end

    it "redirects to the work page if the user has already voted for that work" do
      get login_path
      post upvote_path(Work.find(works(:movie).id))
      post upvote_path(Work.find(works(:movie).id))
      must_redirect_to work_path(Work.find(works(:movie).id))

    end
  end
end
