require 'test_helper'

describe WorksController do
  describe "logged in user" do
    before do
      login(User.first)
    end

    describe "root" do
      it "succeeds with all media types" do
        # Precondition: there is at least one media of each category
        get root_path
        must_respond_with :success

      end

      it "succeeds with one media type absent" do
        # Precondition: there is at least one media in two of the categories
        Work.destroy_all
        data1 = {
          title: "coco",
          creator: "Pixar",
          description: "Best in 2017",
          publication_year: 2017,
          category: "movie"
        }
        data2 = {
          title: "Zootopia",
          creator: "Pixar",
          description: "Best in 2015",
          publication_year: 2016,
          category: "movie"
        }
        data3 = {
          title: "Turing",
          creator: "Hollywood",
          description: "Best in 2015",
          publication_year: 2015,
          category: "book"
        }
        Work.create(data1)
        Work.create(data2)
        Work.create(data3)
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
        Work.count.must_be :>, 0
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
        old_work_count = Work.count
        work_data = {
          category: "movie",
          title: "lolita",
          description: "I just made it up"
        }

        Work.new(work_data).must_be :valid?

        post works_path, params: {work: work_data}

        must_respond_with :redirect
        must_redirect_to work_path(Work.last)

        CATEGORIES.must_include Work.last.category.pluralize
        Work.count.must_equal old_work_count + 1
        Work.last.title.must_equal work_data[:title]
      end

      it "renders bad_request and does not update the DB for bogus data" do
        old_work_count = Work.count
        work_data = {
          category: "movie",
          description: "I just made it up"
        }

        Work.new(work_data).wont_be :valid?

        post works_path, params: {work: work_data}

        must_respond_with :bad_request

        Work.count.must_equal old_work_count
      end

      it "renders 400 bad_request for bogus categories" do
        old_work_count = Work.count
        work_data = {
          category: INVALID_CATEGORIES.sample,
          title: "walawala",
          description: "I just made it up"
        }

        Work.new(work_data).wont_be :valid?

        post works_path, params: {work: work_data}

        must_respond_with :bad_request

        Work.count.must_equal old_work_count
      end

    end

    describe "show" do
      it "succeeds for an extant work ID" do
        work1 = Work.first
        get work_path(work1)
        must_respond_with :success
      end

      it "renders 404 not_found for a bogus work ID" do
        work404 = Work.last.id + 404
        get work_path(work404)
        must_respond_with :not_found
      end
    end

    describe "edit" do
      it "succeeds for an extant work ID" do
        work1 = Work.first
        get work_path(work1)
        must_respond_with :success
      end

      it "renders 404 not_found for a bogus work ID" do
        work404 = Work.last.id + 404
        get work_path(work404)
        must_respond_with :not_found
      end
    end

    describe "update" do
      it "succeeds for valid data and an extant work ID" do
        work1 = Work.first
        work_data = work1.attributes
        work_data[:title] = "huluhulu"

        work1.assign_attributes(work_data)
        work1.must_be :valid?

        patch work_path(work1), params: {work: work_data}

        must_respond_with :redirect
        must_redirect_to work_path(work1)

        work1.reload
        work1.id.must_equal Work.first.id
      end

      it "renders bad_request for bogus data" do
        work1 = Work.first
        work_data = work1.attributes
        work_data[:category] = "instagram"

        work1.assign_attributes(work_data)
        work1.wont_be :valid?

        patch work_path(work1), params: {work: work_data}

        must_respond_with :bad_request

        work1.reload
        work1.category.wont_equal work_data[:category]
      end

      it "renders 404 not_found for a bogus work ID" do
        work404 = Work.last.id + 404
        patch work_path(work404)
        must_respond_with :not_found
      end
    end

    describe "destroy" do
      it "succeeds for an extant work ID" do
        work1 = Work.first
        delete work_path(work1)
        must_respond_with :redirect
        must_redirect_to root_path
      end

      it "renders 404 not_found and does not update the DB for a bogus work ID" do
        work404 = Work.last.id + 404
        delete work_path(work404)
        must_respond_with :not_found
      end
    end

    describe "upvote" do

      it "redirects to the work page after the user has logged out" do
        work1 = Work.last
        post upvote_path(work1)

        delete logout_path
        must_respond_with :redirect
        must_redirect_to root_path
        flash[:result_text] = "Successfully logged out"
      end

      it "succeeds for a logged-in user and a fresh user-vote pair" do
        work_data = {
          category: "movie",
          title: "lolita",
          description: "I just made it up"
        }

        Work.create(work_data)
        work1 = Work.last
        post upvote_path(work1)
        must_respond_with :redirect
        must_redirect_to root_path
      end

      it "redirects to the work page if the user has already voted for that work" do
        work_data = {
          category: "movie",
          title: "lolita",
          description: "I just made it up"
        }

        Work.create(work_data)
        work1 = Work.last

        # first vote
        post upvote_path(work1)
        flash[:result_text].must_equal "Successfully upvoted!"

        # second vote
        post upvote_path(work1)
        flash[:result_text].must_equal "Could not upvote"
      end

    end
  end

  describe "guest user" do
    it "rejects requests for new work form" do
      user = User.first

      get new_work_path
      must_respond_with :bad_request
    end

    it "rejects requests to create a new work" do
      work_data = {
        category: "movie",
        title: "lolita",
        description: "I just made it up"
      }

      Work.new(work_data).must_be :valid?

      post works_path, params: {work: work_data}
      must_respond_with :bad_request
      flash[:error].must_equal "You must log in to do that"

    end


    it "does not allow a guest user to vote" do
      work1 = Work.first

      post upvote_path(work1)
      must_respond_with :bad_request
      flash[:error].must_equal "You must log in to do that"
    end

    it "does not allow a guest user to view a work page" do
      work1 = Work.first
      get work_path(work1)
      must_respond_with :bad_request
      flash[:error].must_equal "You must log in to do that"
    end

    it "does not allow a guest user to edit a work" do
      work1 = Work.first
      get edit_work_path(work1)
      must_respond_with :bad_request
      flash[:error].must_equal "You must log in to do that"
    end

    it "does not allow a guest user to update a work" do
      work1 = Work.first
      patch work_path(work1)
      must_respond_with :bad_request
      flash[:error].must_equal "You must log in to do that"
    end
  end
end
