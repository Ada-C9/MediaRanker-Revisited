require 'test_helper'

describe WorksController do
  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category

      # Assumption
      Work.best_albums.count.must_be :>, 0
      Work.best_books.count.must_be :>, 0
      Work.best_movies.count.must_be :>, 0

      # Act
      get root_path

      # Assert
      must_respond_with :success

    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories

      # Assumption
      Work.best_albums.count.must_be :>, 0
      Work.best_books.count.must_be :>, 0
      Work.where(category: "movie").destroy_all
      Work.best_movies.count.must_be :<=, 0

      # Act
      get root_path

      # Assert
      must_respond_with :success

    end

    it "succeeds with no media" do
      Work.destroy_all
      Work.best_albums.count.must_be :<=, 0
      Work.best_books.count.must_be :<=, 0
      Work.best_movies.count.must_be :<=, 0

      # Act
      get root_path

      # Assert
      must_respond_with :success
    end
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do
    it "succeeds when there are works" do
      # Assumption
      Work.count.must_be :>, 0

      # Act
      get works_path

      # Assert
      must_respond_with :success

    end

    it "succeeds when there are no works" do
      # Assumption
      Work.destroy_all
      Work.count.must_be :<=, 0

      # Act
      get works_path

      # Assert
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

      # Arange
      media_params = {title: "Star Wars ep. IV", creator: "George Lucas", description: "Luke that is your sister", category: "movie", publication_year: "1977"}

      first_media_count = Work.count

      # Assumption

      work = Work.new(media_params)

      work.must_be :valid?


      # Act
      post works_path, params: {work: media_params}


      # Assert
      must_respond_with :redirect
      must_redirect_to work_path(Work.last.id)

      Work.count.must_equal first_media_count + 1
      Work.last.title.must_equal media_params[:title]

    end

    it "renders bad_request and does not update the DB for bogus data" do

      media_params = {title: " ", creator: "George Lucas", description: "Luke that is your sister", category: "unicorns", publication_year: "1977"}

      first_media_count = Work.count

      # Assumption

      work = Work.new(media_params)

      work.wont_be :valid?


      # Act
      post works_path, params: {work: media_params}


      # Assert
      must_respond_with :bad_request


      Work.count.must_equal first_media_count

    end

    it "renders 400 bad_request for bogus categories" do
      media_params = {title: "Star Wars ep. IV", creator: "George Lucas", category: "random"}

      first_media_count = Work.count

      # Assumption

      # Act
      post works_path, params: {work: media_params}


      # Assert
      must_respond_with :bad_request

      Work.count.must_equal first_media_count

    end

  end

  describe "show" do
    it "succeeds for an existant work ID" do
      get work_path(Work.first)

      must_respond_with :success

    end

    it "renders 404 not_found for a bogus work ID" do
      work = Work.last.id + 1
      get work_path(work)

      must_respond_with :not_found

    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do
      get edit_work_path(Work.first.id)

      must_respond_with :success

    end

    it "renders 404 not_found for a bogus work ID" do
      work = Work.last.id + 1
      get edit_work_path(work)

      must_respond_with :not_found


    end
  end

  describe "update" do
    it "succeeds for valid data and an existant work ID" do
      work = Work.first
      work_detail = work.attributes
      work_detail[:title] = 'tanoshi'

      patch work_path(work), params: {work: work_detail}

      must_redirect_to work_path(work)
      work.reload
      work.title.must_equal work_detail[:title]

    end

    it "renders bad_request for bogus data" do
      work = Work.first
      work_detail = work.attributes
      work_detail[:title] = " "

      patch work_path(work), params: {work: work_detail}

      must_respond_with :not_found
      work.reload
      work.title.wont_equal work_detail[:title]


    end

    it "renders 404 not_found for a bogus work ID" do
      work_id = Work.first.id + 1

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
      Work.find_by(id: work_id).must_be_nil


    end
  end

  describe "upvote" do

    work = Work.first

    it "redirects to the work page if no user is logged in" do
      post upvote_path(work)

      must_redirect_to work_path

    end

    it "redirects to the work page after the user has logged out" do
      username = User.first.username

      get login_path, params: {username: username}

      post logout_path

      must_redirect_to root_path


    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      username = User.last.username

      get login_path, params: {username: username}

      post upvote_path(work)

      must_respond_with :redirect

    end


    it "redirects to the work page if the user has already voted for that work" do

      username = User.first.username

      get login_path, params: {username: username}

      post upvote_path(work)
      post upvote_path(work)

      must_redirect_to work_path(work)

    end
  end
end
