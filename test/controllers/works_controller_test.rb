require 'test_helper'

describe WorksController do

  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category
      album = Work.create(title: "Best Album", category: "album")
      book = Work.create(title: "Best Book", category: "book")
      movie = Work.create(title: "Best Movie", category: "movie")

      get root_path
      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      album = Work.create(title: "Best Album", category: "album")
      book = Work.create(title: "Best Book", category: "book")

      get root_path
      must_respond_with :success
    end

    it "succeeds with no media" do
      Work.destroy_all
      get root_path
      must_respond_with :success
    end
  end

  describe "logged in user" do
    CATEGORIES = %w(albums books movies)
    INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

    describe "index" do
      it "succeeds when there are works" do
        user = users(:kari)
        login(user)
        Work.count.must_be :>, 0

        get works_path
        must_respond_with :success
      end

      it "succeeds when there are no works" do
        user = users(:kari)
        login(user)
        Work.destroy_all
        get works_path
        must_respond_with :success
      end
    end

    describe "new" do
      it "succeeds" do
        user = users(:kari)
        login(user)
        get new_work_path
        must_respond_with :success
      end
    end

    describe "create" do
      it "creates a work with valid data for a real category" do
        work_data = { title: "Valid Work", category: "album"}

        old_work_count = Work.count
        user = users(:kari)
        login(user)
        Work.new(work_data).must_be :valid?

        post works_path, params: { work: work_data }
        must_respond_with :redirect
        must_redirect_to work_path(Work.last)
      end

      it "renders bad_request and does not update the DB for bogus data" do
        old_work_count = Work.count

        work_data = { title: "", category: "not a category" }
        user = users(:kari)
        login(user)
        Work.new(work_data).wont_be :valid?

        post works_path, params: { work: work_data }
        must_respond_with :bad_request
        Work.count.must_equal old_work_count
      end

      it "renders 400 bad_request for bogus categories" do
        old_work_count = Work.count
        user = users(:kari)
        login(user)
        work_data = { title: "A Title", category: "not a category" }
        Work.new(work_data).wont_be :valid?

        post works_path, params: { work: work_data }
        must_respond_with :bad_request
        must_respond_with 400
        Work.count.must_equal old_work_count
      end
    end

    describe "show" do
      it "succeeds for an extant work ID" do
        user = users(:kari)
        login(user)
        votes = Work.first.votes.order(created_at: :desc)

        get work_path(Work.first)
        must_respond_with :success
      end

      it "renders 404 not_found for a bogus work ID" do
        user = users(:kari)
        login(user)
        bogus_work_id = Work.last.id + 1
        get work_path(bogus_work_id)
        must_respond_with 404
        must_respond_with :not_found
      end
    end

    describe "edit" do
      it "succeeds for an extant work ID" do
        user = users(:kari)
        login(user)
        work_id = Work.first
        get edit_work_path(work_id)
        must_respond_with :success
      end

      it "renders 404 not_found for a bogus work ID" do
        user = users(:kari)
        login(user)
        bogus_work_id = Work.last.id + 1
        get edit_work_path(bogus_work_id)
        must_respond_with :not_found
        must_respond_with 404
      end
    end

    describe "update" do
      it "succeeds for valid data and an extant work ID" do
        user = users(:kari)
        login(user)
        work = Work.first
        work_data = Work.first.attributes
        work_data[:title] = "New Valid Title"

        patch work_path(work.id), params: { work: work_data }
        must_respond_with :redirect
        must_redirect_to work_path(work)

        work.reload

        work.title.must_equal work_data[:title]
      end

      it "renders not_found for bogus data" do
        user = users(:kari)
        login(user)
        work = Work.first
        work_data = Work.first.attributes
        work_data[:title] = ""

        patch work_path(work.id), params: { work: work_data }
        must_respond_with :not_found

        work.reload

        work.title.wont_equal work_data[:title]
      end

      it "renders 404 not_found for a bogus work ID" do
        user = users(:kari)
        login(user)
        work_id = Work.last.id + 1
        patch work_path(work_id)
        must_respond_with :not_found
        must_respond_with 404
      end
    end

    describe "destroy" do
      it "succeeds for an extant work ID" do
        user = users(:kari)
        login(user)
        work_id = Work.first.id
        old_count = Work.count

        delete work_path(work_id)

        must_respond_with :redirect
        must_redirect_to root_path

        Work.count.must_equal old_count - 1
        Work.find_by(id: work_id).must_be_nil
      end

      it "renders 404 not_found and does not update the DB for a bogus work ID" do
        user = users(:kari)
        login(user)
        work_id = Work.last.id + 1
        old_count = Work.count
        delete work_path(work_id)

        must_respond_with :not_found
        must_respond_with 404
        Work.count.must_equal old_count
      end
    end

    describe "upvote" do

      it "succeeds for a logged-in user and a fresh user-vote pair" do
        Vote.destroy_all
        User.destroy_all

        user = User.create(
          username: "Anne",
          email: "annehwatson@gmail.com",
          uid: 999999,
          provider: "github"
        )

        work = works(:album)

        login(user)

        post upvote_path(work)
        flash[:status].must_equal :success
        flash[:result_text].must_equal "Successfully upvoted!"
        must_respond_with :redirect
        must_redirect_to work_path(work)

      end

      it "redirects to the work page if the user has already voted for that work" do
        user = users(:kari)
        login(user)

        work = works(:album)
        post upvote_path(work)
        post upvote_path(work)

        flash[:status].must_equal :failure
        flash[:result_text].must_equal "Could not upvote"

        must_respond_with :redirect
        must_redirect_to work_path(work)
      end
    end
  end

  describe "guest user" do
    describe "index" do
      it "cannot view index" do
        get works_path

        must_respond_with :redirect
        must_redirect_to root_path
      end
    end

    describe "new" do
      it "does not succeed" do
        get new_work_path
        must_respond_with :redirect
        must_redirect_to root_path
      end
    end

    describe "create" do
      it "does not succeed" do
        old_work_count = Work.count
        post works_path, params: { new_work:
          {
          title: "Best Work",
          category: "book"
          }
        }

        must_respond_with :redirect
        must_redirect_to root_path
        Work.count.must_equal old_work_count
      end
    end

    describe "show" do
      it "cannot see work show pages" do
        work = works(:album)
        get work_path(work)
        must_respond_with :redirect
        must_redirect_to root_path
      end
    end

    describe "edit" do
      it "cannot access edit form" do
        work = works(:album)

        get edit_work_path(work)

        must_respond_with :redirect
        must_redirect_to root_path
      end
    end

    describe "update" do
      it "cannot update works" do
        work = works(:album)

        patch work_path(work.id), params: {
          changes: {
            title: "Better Title"
          }
        }

        must_respond_with :redirect
        must_redirect_to root_path
      end
    end

    describe "destroy" do
      it "cannot delete a work" do
        work = works(:album)

        delete work_path(work)

        must_respond_with :redirect
        must_redirect_to root_path
      end
    end

    describe "upvote" do
      it "cannot upvote" do
        work = works(:album)

        post upvote_path(work)

        must_respond_with :redirect
        must_redirect_to root_path
      end
    end

  end

end
