require 'test_helper'

describe WorksController do
  let(:all_works) {Work.all}
  let(:no_works) {Work.all.each { |work| work.destroy } }
  let(:bogus_id) { 5000 }

  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category
      get root_path
      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      works(:movie).destroy
      get root_path
      must_respond_with :success
    end

    it "succeeds with no media" do
      no_works
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
      no_works
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
          work: {title: "new movie", creator: "me", description: "some description", publication_year: 1955, category: CATEGORIES[0]}
        }
      }.must_change 'Work.count', 1

      work = Work.last
      must_respond_with :redirect
      must_redirect_to work_path(work.id)
    end

    it "renders bad_request and does not update the DB for bogus data" do
      proc {
        post works_path, params: {
          work: {title: nil, creator: "me", description: "some description", publication_year: 1955, category: "album"}
        }
      }.must_change 'Work.count', 0
      must_respond_with :bad_request
    end

    it "renders 400 bad_request for bogus categories" do
      INVALID_CATEGORIES.each do |category|
        proc {
          post works_path, params: {
            work: {title: "new work", creator: "me", description: "some description", publication_year: 1955, category: category}
          }
        }.must_change 'Work.count', 0
        must_respond_with :bad_request
      end
    end

  end

  describe "show" do
    it "succeeds for an extant work ID" do
      get work_path(works(:poodr).id)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      get work_path(bogus_id)
      must_respond_with :not_found
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do
      get edit_work_path(works(:poodr).id)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      get edit_work_path(bogus_id)
      must_respond_with :not_found
    end
  end

  describe "update" do
    it "succeeds for valid data and an extant work ID" do
      updated_title = "updated title"
      proc {
        put work_path(works(:album).id), params: {
          work: {title: updated_title}
        }
      }.must_change 'Work.count', 0

      work = Work.find(works(:album).id)
      work.title.must_equal updated_title
      work.creator.must_equal "You Create"

      must_respond_with :redirect
    end

    it "renders bad_request for bogus data" do
      bogus_title = nil
      put work_path(works(:album).id), params: {
        work: {title: bogus_title}
      }
      must_respond_with :not_found
    end

    it "renders 404 not_found for a bogus work ID" do
      put work_path(bogus_id)
      must_respond_with :not_found
    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do
      initial_count = all_works.count

      delete work_path(works(:movie).id)

      new_count = all_works.count
      new_count.must_equal initial_count - 1
      must_redirect_to root_path
      must_respond_with :found
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      proc {
        delete work_path(bogus_id)
      }.must_change 'Work.count', 0
      must_respond_with :not_found
    end
  end

  describe "upvote" do

    it "redirects to the work page if no user is logged in" do
      post upvote_path(works(:poodr).id)
      must_redirect_to work_path(works(:poodr).id)
    end

    it "redirects to the work page after the user has logged out" do
      # get login_path, params: {name: "new user"}
      post logout_path
      must_redirect_to root_path
    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      get login_path, params: { username: "new user" }
      # work = works(:poodr)
      binding.pry
      proc {
        post upvote_path(works(:poodr).id)
      }.must_change 'Vote.count', 1
    end

    it "redirects to the work page if the user has already voted for that work" do
      skip
    end
  end
end
