require 'test_helper'

describe WorksController do
  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category
      Work.where(category: 'album').count.must_be :>=, 1
      Work.where(category: 'book').count.must_be :>=, 1
      Work.where(category: 'movie').count.must_be :>=, 1

      # Act
      get root_path

      # Assert
      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      # Arrange
      Work.where(category: 'movie').destroy_all

      Work.where(category: 'album').count.must_be :>=, 1
      Work.where(category: 'book').count.must_be :>=, 1

      # Act
      get root_path

      # Assert
      must_respond_with :success
    end

    it "succeeds with no media" do
      # Arrange
      Work.destroy_all

      # Assumptions
      Work.count.must_equal 0

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
      # Assumptions
      Work.count.must_be :>, 0

      # Act
      get works_path

      # Assert
      must_respond_with :success
    end

    it "succeeds when there are no works" do
      # Arrange
      Work.destroy_all

      # Assumptions
      Work.count.must_equal 0

      # Act
      get works_path

      # Assert
      must_respond_with :success

    end
  end

  describe "new" do
    it "succeeds" do
      # Act
      get new_work_path

      #Assert
      must_respond_with :success
    end
  end

  describe "create" do
    it "creates a work with valid data for a real category" do
      # Arrange
      before_count = Work.count

      work_data = {
        title: "test title",
        creator: "test creator",
        description: "test description",
        publication_year: "2016-04-08",
        category: "album"
      }

      # Assumptions
      Work.new(work_data).must_be :valid?

      # Act
      post works_path, params: { work: work_data }

      # Assert
      must_respond_with :redirect
      must_redirect_to work_path(Work.last.id)
      Work.count.must_equal before_count + 1
      Work.last.title.must_equal work_data[:title]
    end

    it "renders bad_request and does not update the DB for bogus data" do
      # Arrange
      before_count = Work.count

      work_data = {
        title: "",
        creator: "",
        description: "",
        publication_year: "",
        category: "album"
      }

      # Assumptions
      Work.new(work_data).wont_be :valid?

      # Act
      post works_path, params: { work: work_data }

      # Assert
      must_respond_with :bad_request
      Work.count.must_equal before_count
    end

    it "renders 400 bad_request for bogus categories" do
      # Arrange
      before_count = Work.count

      work_data = {
        title: "test title",
        creator: "test creator",
        description: "test description",
        publication_year: "2016-04-08",
        category: "42"
      }

      # Assumptions
      Work.new(work_data).wont_be :valid?

      # Act
      post works_path, params: { work: work_data }

      # Assert
      must_respond_with :bad_request
      Work.count.must_equal before_count
    end

  end

  describe "show" do
    it "succeeds for an extant work ID" do
      # Arrange
      work = Work.first

      # Assumptions
      work.must_be :valid?

      # Act
      get work_path(work)

      # Assert
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do

    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do

    end

    it "renders 404 not_found for a bogus work ID" do

    end
  end

  describe "update" do
    it "succeeds for valid data and an extant work ID" do

    end

    it "renders bad_request for bogus data" do

    end

    it "renders 404 not_found for a bogus work ID" do

    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do

    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do

    end
  end

  describe "upvote" do

    it "redirects to the work page if no user is logged in" do

    end

    it "redirects to the work page after the user has logged out" do

    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do

    end

    it "redirects to the work page if the user has already voted for that work" do

    end
  end
end
