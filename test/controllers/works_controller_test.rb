require 'test_helper'

# Works controller responsible for:


describe WorksController do
  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category
      # Arrange
      Work.where(category: "album").count.must_be :>, 0
      Work.where(category: "book").count.must_be :>, 0
      Work.where(category: "movie").count.must_be :>, 0

      # #Act
      get root_path
      # # Assert
      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      skip
      # Precondition: there is at least one media in two of the categories
      # Arrange
      Work.where(category: "album").count.must_be :>, 0
      Work.where(category: "book").count.must_be :>, 0
      # must delete all movies so that none exit in that category
      Work.where(category: "movie").destroy.count.must_be :==, 0

      # Act
      get root_path
      # Assert
      must_respond_with :success
    end

    it "succeeds with no media" do
      # Arrange
      Work.destroy_all
      Work.all.length.must_equal 0
      # Act
      get works_path
      # Assert
      must_respond_with :success
    end
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do
    it "succeeds when there are works" do
      # get works
      Work.all.count.must_be :>, 0
      get works_path
      must_respond_with :success
    end

    it "succeeds when there are no works" do
      # Arrange
      Work.destroy_all
      Work.all.length.must_equal 0
      # Act
      get works_path
      # Assert
      must_respond_with :success
    end
  end

  describe "new" do
    it "succeeds" do

    end
  end

  describe "create" do
    it "creates a work with valid data for a real category" do

    end

    it "renders bad_request and does not update the DB for bogus data" do

    end

    it "renders 400 bad_request for bogus categories" do

    end

  end

  describe "show" do
    it "succeeds for an extant work ID" do

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
