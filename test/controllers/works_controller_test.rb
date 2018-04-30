require 'test_helper'

describe WorksController do

  categories = %w(albums books movies)
  invalid_categories = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "logged in users" do
    before do
      login(users(:test))
    end

    describe "index" do
      it "succeeds when there are works" do
        Work.count.must_be :>, 0

        get works_path
        must_respond_with :success
      end

      it "succeeds when there are no works" do
        Work.destroy_all
        Work.where(category: "movie").count.must_equal 0

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
        work_data = {
          title: 'c test title',
          creator: 'c test creator',
          description: 'c test description',
          category: categories[0],
          publication_year: 2018
        }
        original_count = Work.count

        work = Work.new(work_data)
        work.must_be :valid?

        post works_path, params: { work: work_data }

        must_respond_with :redirect
        must_redirect_to work_path(Work.last)
        Work.count.must_equal original_count + 1
        Work.last.title.must_equal 'c test title'
      end

      it "renders bad_request and does not update the db for bogus data" do
        work_data = {
          title: '',
          creator: 'c test creator',
          description: 'c test description',
          category: categories[0],
          publication_year: 2018
        }
        original_count = Work.count

        Work.new(work_data).wont_be :valid?

        post works_path, params: { work: work_data }

        must_respond_with :bad_request
        Work.count.must_equal original_count
      end

      it "renders 400 bad_request for bogus categories" do
        work_data = {
          title: 'c test title',
          creator: 'controller test creator',
          description: 'controller test description',
          category: invalid_categories[0],
          publication_year: 2018
        }
        original_count = Work.count

        Work.new(work_data).wont_be :valid?

        post works_path, params: { work: work_data }

        must_respond_with :bad_request
        Work.count.must_equal original_count
      end

    end

    describe "show" do
      it "succeeds for an extant work id" do
        work_id = Work.first

        get work_path(work_id)
        must_respond_with :success
      end

      it "renders 404 not_found for a bogus work id" do
        work_id = Work.last.id + 1

        get work_path(work_id)
        must_respond_with :not_found
      end
    end

    describe "edit" do
      it "succeeds for an extant work id" do
        work_id = Work.first

        get edit_work_path(work_id)
        must_respond_with :success
      end

      it "renders 404 not_found for a bogus work id" do
        work_id = Work.last.id + 1

        get work_path(work_id)
        must_respond_with :not_found
      end
    end

    describe "update" do
      it "succeeds for valid data and an extant work id" do
        work = works(:poodr)

        work_data = {
          title: 'c test title'
        }

        work.must_be :valid?

        patch work_path(work), params: { work: work_data }

        must_respond_with :redirect
        must_redirect_to work_path(work)

        work.reload
        work.title.must_equal 'c test title'
      end

      it "renders not_found for bogus data" do
        work = works(:poodr)

        work_data = {
          title: ''
        }

        work.must_be :valid?

        patch work_path(work), params: { work: work_data }

        must_respond_with :not_found
        work.reload
        work.title.wont_equal ''
      end

      it "renders 404 not_found for a bogus work id" do
        work_id = Work.last.id + 1

        patch work_path(work_id)

        must_respond_with :not_found
      end
    end

    describe "destroy" do
      it "succeeds for an extant work id" do
        work = Work.first
        original_count = Work.count

        delete work_path(work.id)

        must_respond_with :redirect
        must_redirect_to root_path

        Work.count.must_equal original_count - 1
      end

      it "renders 404 not_found and does not update the db for a bogus work id" do
        work_id = Work.last.id + 1
        original_count = Work.count

        delete work_path(work_id)

        must_respond_with :not_found

        Work.count.must_equal original_count
      end
    end
  end

  describe "upvote" do
    before do
      @work = Work.first
      @username = users(:dan).username
      @provider = users(:dan).provider
    end

    it "redirects to the work page if no user is logged in" do
      get auth_callback_path @provider

      post upvote_path(@work)

      must_respond_with :redirect
      must_redirect_to work_path(@work)
    end

#     it "redirects to the work page after the user has logged out" do
#       # login
#       get auth_callback_path @provider
#
#       # logout
#       delete logout_path @provider
#
#       # vote
#       post upvote_path(@work)
#
#       must_respond_with :redirect
#       must_redirect_to work_path(@work)
#     end
#
#     it "succeeds for a logged-in user and a fresh user-vote pair" do
#       # login
#       get auth_callback_path @provider
#
#       post upvote_path(@work)
#
#       must_respond_with :redirect
#       must_redirect_to work_path(@work)
#     end
#
#     it "redirects to the work page if the user has already voted for that work" do
#       # login
#       get auth_callback_path @provider
#
#       # first vote
#       post upvote_path(@work)
#       # attempted second vote
#       post upvote_path(@work)
#
#       must_respond_with :redirect
#       must_redirect_to work_path(@work)
#     end
  end

  describe "guest users" do
    describe "root" do
      it "succeeds with all media types" do
        # precondition: there is at least one media of each category
        Work.where(category: "album").count.must_be :>, 0
        Work.where(category: "book").count.must_be :>, 0
        Work.where(category: "movie").count.must_be :>, 0

        get root_path
        must_respond_with :success
      end

      it "succeeds with one media type absent" do
        # precondition: there is at least one media in two of the categories
        Work.where(category: "album").count.must_be :>, 0
        Work.where(category: "book").count.must_be :>, 0

        Work.where(category: "movie").destroy_all

        Work.where(category: "movie").count.must_equal 0
      end

      it "succeeds with no media" do
        Work.destroy_all

        get root_path
        must_respond_with :success
      end
    end

    it "can access the 'view to media' page" do
      get root_path
      must_respond_with :success
    end

    it "cannot access the 'view all media' page" do
      get works_path
      must_redirect_to root_path
      flash[:result_text].must_equal "Please log in to do that."
    end

    it "cannot access the 'add a new work' page" do
      get new_work_path
      must_redirect_to root_path
      flash[:result_text].must_equal "Please log in to do that."
    end

    it "cannot access the 'view all users' page" do
      get users_path
      must_redirect_to root_path
      flash[:result_text].must_equal "Please log in to do that."
    end
  end
end
