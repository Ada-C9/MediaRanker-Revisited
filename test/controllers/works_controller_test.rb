require 'test_helper'

describe WorksController do
  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category

      albums = Work.where(category: 'album')
      books = Work.where(category: 'book')
      movies = Work.where(category: 'movie')

      albums.count.must_be :>, 0
      books.count.must_be :>, 0
      movies.count.must_be :>, 0

      get root_path

      must_respond_with :success

    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      albums = Work.where(category: 'album')
      albums.destroy_all

      albums.count.must_equal 0

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

      Work.count.must_equal 0

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
        title: 'A Test Title',
        category: 'albums'
      }

      before_count = Work.count
      Work.new(work_data).must_be :valid?

      post works_path, params: {work: work_data}

      work = Work.last
      must_redirect_to work_path(work.id)
      Work.count.must_equal before_count + 1
    end

    it "renders bad_request and does not update the DB for bogus data" do
      work_data = {
        title: nil,
        category: 'albums'
      }

      before_count = Work.count
      Work.new(work_data).wont_be :valid?

      post works_path, params: {work: work_data}

      must_respond_with :bad_request
      Work.count.must_equal before_count
    end

    it "renders 400 bad_request for bogus categories" do
      work_data = {
        title: 'Test Title',
        category: INVALID_CATEGORIES[0]
      }

      before_count = Work.count

      post works_path, params: {work: work_data}

      must_respond_with :bad_request
      Work.count.must_equal before_count
    end

  end

  describe "show" do
    it "succeeds for an extant work ID" do
      work = Work.first

      get work_path(work.id)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      work_id = Work.last.id + 1

      get work_path(work_id)

      must_respond_with :not_found
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do
      work = Work.first

      get edit_work_path(work.id)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      work_id = Work.last.id + 1

      get work_path(work_id)

      must_respond_with :not_found
    end
  end

  describe "update" do
    let (:work) { Work.first }

    it "succeeds for valid data and an extant work ID" do
      work_params = {
        title: 'my_title'
      }
      work.assign_attributes(work_params)

      work.valid?.must_equal true

      patch work_path(work.id), params: {work: work_params}

      must_redirect_to work_path(work.id)
      Work.first.title.must_equal 'my_title'
    end

    it "renders not_found for bogus data" do
      work_params = {
        category: INVALID_CATEGORIES[-1]
      }

      work.assign_attributes(work_params)

      work.valid?.must_equal false

      patch work_path(work.id), params: {work: work_params}

      must_respond_with :not_found
      work.category.must_equal work_params[:category]
      work.errors.messages.must_include :category
    end

    it "renders 404 not_found for a bogus work ID" do
      work_id = Work.last.id + 1
      work_params = {
        title: 'my_title'
      }
      work.assign_attributes(work_params)

      patch work_path(work_id), params: {work: work_params}

      must_respond_with :not_found
    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do
      work = Work.first
      old_count = Work.count

      delete work_path(work.id)

      must_redirect_to root_path
      Work.count.must_equal old_count - 1
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      work_id = Work.last.id + 1
      old_count = Work.count

      delete work_path(work_id)

      must_respond_with :not_found
      Work.count.must_equal old_count

    end
  end

  describe "upvote" do

    it "redirects to the work page if no user is logged in" do
      work = Work.first
      old_count = work.vote_count

      post upvote_path(work.id)

      must_redirect_to work_path(work.id)
      Work.first.vote_count.must_equal old_count
    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      user = User.first
      work = Work.create!(title: 'A new work', category: 'books')

      login(user)
      session[:user_id].must_equal user.id

      post upvote_path(work.id)

      must_redirect_to work_path(work.id)
      work.reload
      work.vote_count.must_equal 1
    end

    it "redirects to the work page if the user has already voted for that work" do
      work = works(:another_album)
      user = users(:dan)

      login(user)
      session[:user_id].must_equal user.id

      old_vote_count = work.vote_count

      # Act
      post upvote_path(work.id)

      # Assert
      works(:another_album).vote_count.must_equal old_vote_count
      must_redirect_to work_path(work.id)
    end
  end
end
