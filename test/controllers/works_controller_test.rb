require 'test_helper'

describe WorksController do
  describe "root" do
    # let(:album) { works(:album)}
    # let(:book) {works(:poodr)}
    # let(:movie) {works(:movie)}
    # let(:album_two) {works(:another_album)}

    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category

      get root_path
      must_respond_with :success

    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      Work.find(works(:poodr).id).destroy


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
        post works_path, params: {
          work: {
            category: "book",
            title: "Coraline",
            creator: "Neil Gaiman"
          }
        }
      }.must_change 'Work.count', 1

      id_of_new_work = Work.find_by(title: "Coraline").id

      must_respond_with :redirect
      must_redirect_to work_path id_of_new_work
    end

    it "renders bad_request and does not update the DB for bogus data" do

      proc {
        post works_path, params: {
          work: {
            category: "book"
          }
        }
      }.must_change 'Work.count', 0


      post works_path
      must_respond_with :bad_request
    end

    it "renders 400 bad_request for bogus categories" do
      proc {
        post works_path, params: {
          work: {
            category: "nope",
            title: "Coraline"
          }
        }
      }.must_change 'Work.count', 0


      post works_path
      must_respond_with :bad_request
    end

  end

  describe "show" do
    it "succeeds for an existent work ID" do
      get works_path(works(:poodr).id)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      works(:poodr).id = 'notanid'

      get work_path(works(:poodr).id)

      must_respond_with :not_found
    end
  end

  describe "edit" do
    it "succeeds for an existent! work ID" do
      get edit_work_path works(:poodr).id

    must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do

      works(:poodr).id = 'notanid'
      get work_path(works(:poodr).id)

      must_respond_with :not_found
    end
  end

  describe "update" do
    it "succeeds for valid data and an existent! work ID" do
      put work_path works(:poodr).id, params: {
      work: {
        category: "book",
        title: "Coraline",
        creator: "Neil Gaiman"
      }
    }

    updated_work = Work.find(works(:poodr).id)

    updated_work.title.must_equal "Coraline"

    must_respond_with :redirect
    end

    it "renders not_found for bogus data" do
      put work_path works(:poodr).id, params: {
      work: {
        category: "nope",
        title: " "
      }
    }

    must_respond_with :not_found

    end

    it "renders 404 not_found for a bogus work ID" do
      works(:poodr).id = 'notanid'
      put work_path(works(:poodr).id)

      must_respond_with :not_found
    end
  end

  describe "destroy" do
    it "succeeds for an existent work ID" do

      proc {delete work_path(works(:poodr).id) }.must_change 'Work.count', -1

      must_respond_with :redirect
      must_redirect_to root_path

    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      proc {delete work_path('nope') }.must_change 'Work.count', 0

      must_respond_with :not_found
    end
  end

  describe "upvote" do

    it "redirects to the work page if no user is logged in" do
      post upvote_path(works(:poodr).id)

      must_redirect_to work_path(works(:poodr).id)
    end

    it "redirects to the work * YOU MEAN ROOT PATH * page after the user has logged out" do
      post logout_path
      must_redirect_to root_path
      #is this right?!
    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      user = users(:kari)
      session[:user_id] = user.id
      post login_path
      post upvote_path(works(:poodr).id)

      must_respond_with :success
    end

    it "redirects to the work page if the user has already voted for that work" do
      skip
    end
  end
end
