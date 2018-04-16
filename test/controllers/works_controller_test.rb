require 'test_helper'

describe WorksController do
  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category
      %w(albums books movies).each do |category|
        Work.by_category(category).length.must_be :>,0

        get root_path

      end
    end
    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      %w(albums movies).each do |category|
        Work.by_category(category).length.must_be :>,0

        Work.by_category(:books).destroy_all

        get root_path

        must_respond_with :success
      end
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
      # Arrange - for each category
      CATEGORIES.each do |category|
        Work.by_category(category).length.must_be :>,0

        get works_path(category)

        must_respond_with :success
      end
    end

    it "succeeds when there are no works" do
      # Arrange - for each category
      CATEGORIES.each do |category|
        Work.destroy_all

        get works_path

        must_respond_with :success
      end
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
        title: "fake title",
        category: "album"
      }

      counting = Work.count

      Work.new(work_data).must_be :valid?

      post works_path, params: {work: work_data}

      must_respond_with :redirect
      must_redirect_to work_path(Work.last.id)

      Work.count.must_equal counting + 1
      Work.last.title.must_equal work_data[:title]
    end

    it "renders bad_request and does not update the DB for bogus data" do
      work_data = {
        title: " ",
        category: "movie"
      }

      counting = Work.count

      Work.new(work_data).wont_be :valid?

      post works_path, params: { work: work_data}

      must_respond_with :bad_request
      Work.count.must_equal counting
    end

    it "renders 400 bad_request for bogus categories" do
      work_data = {
        title: "test title",
        category: INVALID_CATEGORIES.sample
      }

      counting = Work.count

      Work.new(work_data).wont_be :valid?

      post works_path, params: { work: work_data}

      must_respond_with :bad_request
      Work.count.must_equal counting
    end
  end

  describe "show" do
    it "succeeds for an extant work ID" do
      skip
    end

    it "renders 404 not_found for a bogus work ID" do
      skip
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do
      skip
    end

    it "renders 404 not_found for a bogus work ID" do
      skip
    end
  end

  describe "update" do
    it "succeeds for valid data and an extant work ID" do
      skip
    end

    it "renders bad_request for bogus data" do
      skip
    end

    it "renders 404 not_found for a bogus work ID" do
      skip
    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do
      skip
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      skip
    end
  end

  describe "upvote" do

    it "redirects to the work page if no user is logged in" do
      skip
    end

    it "redirects to the work page after the user has logged out" do
      skip
    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      skip
    end

    it "redirects to the work page if the user has already voted for that work" do
      skip
    end
  end
end
