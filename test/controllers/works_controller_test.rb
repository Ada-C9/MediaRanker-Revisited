require 'test_helper'

describe WorksController do
  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category

      Work.where(category: 'album').length.must_be :>, 0
      Work.where(category: 'book').length.must_be :>, 0
      Work.where(category: 'movie').length.must_be :>, 0

      get root_path

      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories

      movies = Work.where(category: 'movie')
      movies.each do |movie|
        movie.delete
      end

      Work.where(category: 'movie').length.must_be :<, 1

      get root_path

      must_respond_with :success

    end

    it "succeeds with no media" do

      @albums = []
      @books = []
      @movies = []

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

      @albums = []
      @books = []
      @movies = []

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
        title: "OMG best book",
        category: "movies"
      }
      work_count = Work.count

      Work.new(work_data).must_be :valid?

      post works_path, params: {work: work_data}

      must_respond_with :redirect
      must_redirect_to work_path(Work.last.id)

      Work.count.must_equal work_count + 1
      Work.last.title.must_equal work_data[:title]

    end

    it "renders bad_request and does not update the DB for bogus data" do

      work_data = {
        category: "movies"
      }
      work_count = Work.count

      Work.new(work_data).wont_be :valid?

      post works_path, params: {work: work_data}

      must_respond_with :bad_request

      Work.count.must_equal work_count

    end

    it "renders 400 bad_request for bogus categories" do

      work_data = {
        title: "hot new stuff",
        category: " "
      }
      work_count = Work.count

      Work.new(work_data).wont_be :valid?

      post works_path, params: {work: work_data}

      must_respond_with :bad_request

      Work.count.must_equal work_count

    end

  end

  describe "show" do
    it "succeeds for an extant work ID" do
      get work_path(Work.first)
      must_respond_with :success

    end

    it "renders 404 not_found for a bogus work ID" do
      get work_path(Work.last.id + 1)
      must_respond_with :not_found
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do
      get edit_work_path(Work.first)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      get edit_work_path(Work.last.id + 1)
      must_respond_with :not_found
    end
  end

  describe "update" do
    it "succeeds for valid data and an extant work ID" do

      work = Work.first
      work_data = work.attributes
      work_data[:title] = "So Updated, Much Change"
      work.assign_attributes(work_data)
      work.must_be :valid?

      patch work_path(work), params: { work: work_data}

      work.reload
      work.title.must_equal work_data[:title]

    end

    it "renders 404 not_found for bogus data" do
      work = Work.first
      work_data = work.attributes
      work_data[:title] = nil
      work.assign_attributes(work_data)
      work.wont_be :valid?

      patch work_path(work), params: { work: work_data}

      must_respond_with :not_found
    end

    it "renders 404 not_found for a bogus work ID" do
      work_id = Work.last.id + 1
      patch work_path(work_id)
      must_respond_with :not_found
    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do
      work_id = Work.first.id
      work_count = Work.count

      delete work_path(work_id)

      must_respond_with :redirect
      must_redirect_to root_path

      Work.count.must_equal work_count - 1
      Work.find_by(id: work_id).must_be_nil
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      work_id = Work.last.id + 1
      work_count = Work.count

      delete work_path(work_id)
      must_respond_with :not_found
      Work.count.must_equal work_count
    end
  end

  describe "upvote" do

    it "redirects to the work page if no user is logged in" do

      

      must_respond_with :redirect
      must_redirect_to work_path(work)
    end
  #
  #   it "redirects to the work page after the user has logged out" do
  #
  #   end
  #
  #   it "succeeds for a logged-in user and a fresh user-vote pair" do
  #
  #   end
  #
  #   it "redirects to the work page if the user has already voted for that work" do
  #
  #   end
  end
end
