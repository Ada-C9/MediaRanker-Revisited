require 'test_helper'

describe WorksController do
  let (:user) { users(:kari) }

  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category
      ["album", "book", "movie"].each do |category|
        Work.by_category(category).length.must_be :>, 0
      end
      get root_path
      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      ["album", "book", "movie"].each do |category|
        Work.by_category(category).length.must_be :>, 0
      end

      Work.by_category("book").destroy_all

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
      login(user)
      Work.count.must_be :>, 0
      get works_path
      must_respond_with :success
    end

    it "succeeds when there are no works" do
      login(user)
      Work.destroy_all
      get works_path
      must_respond_with :success
    end
  end

  describe "new" do
    it "succeeds" do
      login(user)
      get new_work_path
      must_respond_with :success
    end
  end

  describe "create" do
    it "creates a work with valid data for a real category" do
      login(user)
      work_data = {
        work: {
          title: "test work"
        }
      }
      CATEGORIES.each do |category|
        work_data[:work][:category] = category

        start_count = Work.count

        post works_path, params: work_data
        must_redirect_to work_path(Work.last)

        Work.count.must_equal start_count + 1
      end

    end

    it "renders bad_request and does not update the DB for bogus data" do
      login(user)
      work_data = {
        work: {
          title: ""
        }
      }
      CATEGORIES.each do |category|
        work_data[:work][:category] = category

        start_count = Work.count

        post works_path, params: work_data
        must_respond_with 400

        Work.count.must_equal start_count
      end
    end

    it "renders 400 bad_request for bogus categories" do
      login(user)
      work_data = {
        work: {
          title: "test work"
        }
      }
      INVALID_CATEGORIES.each do |category|
        work_data[:work][:category] = category

        start_count = Work.count

        post works_path, params: work_data
        must_respond_with 400

        Work.count.must_equal start_count
      end
    end
  end

  describe "show" do
    it "succeeds for an extant work ID" do
      login(user)
      get work_path(Work.first.id)
      must_respond_with :success
      get work_path(Work.last.id)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      login(user)
      work_id = Work.last.id + 1
      get work_path(work_id)
      must_respond_with 404
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do
      login(user)
      get edit_work_path(Work.first.id)
      must_respond_with :success
      get edit_work_path(Work.last.id)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      login(user)
      work_id = Work.last.id + 1
      get edit_work_path(work_id)
      must_respond_with :not_found
    end
  end

  describe "update" do
    it "succeeds for valid data and an extant work ID" do
      login(user)
      updated_title = "Title"

      patch work_path(works(:poodr).id), params: {
        work: {
          title: updated_title
        }
      }

      updated_work = Work.find(works(:poodr).id)
      updated_work.title.must_equal updated_title
      must_respond_with :redirect
      must_redirect_to work_path(works(:poodr).id)
    end

    it "renders bad_request for bogus data" do
      login(user)
      updated_title = " "

      patch work_path(works(:poodr).id), params: {
        work: {
          title: updated_title
        }
      }
      must_respond_with 404
    end

    it "renders 404 not_found for a bogus work ID" do
      login(user)
      work_id = Work.last.id + 1
      get work_path(work_id)
      must_respond_with 404
    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do
      login(user)
      work_id = Work.first.id

      delete work_path(work_id)
      must_redirect_to root_path

      Work.find_by(id: work_id).must_be_nil
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      login(user)
      start_count = Work.count

      work_id = Work.last.id + 1
      delete work_path(work_id)
      must_respond_with 404

      Work.count.must_equal start_count
    end
  end

  describe "upvote" do
    let(:work) { Work.first }

    # it "redirects to the work page if no user is logged in" do
    #   post upvote_path(work)
    #   must_respond_with :redirect
    #   must_redirect_to work_path(work.id)
    # end

    it "redirects to the main page if no user is logged in" do
      post upvote_path(work)
      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "redirects to the main page after the user has logged out" do
      login(user)
      delete logout_path
      post upvote_path(work)
      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      login(user)
      work = works(:another_album)
      post upvote_path(work)
      flash[:status].must_equal :success
      must_respond_with :redirect
      must_redirect_to work_path
    end

    it "redirects to the work page if the user has already voted for that work" do
      login(user)
      work = works(:album)
      post upvote_path(work)
      flash[:status].must_equal :failure
      must_respond_with :redirect
      must_redirect_to work_path
    end
  end
end
