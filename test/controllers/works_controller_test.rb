require 'test_helper'

describe WorksController do
  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category

      #check precondition
      categories = %w(book album movie)
      check = []

      categories.each do |category|
        work = Work.find_by(category: category)
        check << work
      end

      check.each do |work|
        work.must_be :valid?
      end

      get root_path

      must_respond_with :success

    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories

      work_to_delete = Work.where(category: "album")

      work_to_delete.each do |work|
        work.destroy
      end

      #check precondition

      Work.where(category: "album").must_be :empty?

      get root_path

      must_respond_with :success

    end

    it "succeeds with no media" do

      works = Work.all
      works.each { |work| work.destroy }

      #test precondition
      Work.count.must_equal 0

      get root_path

      must_respond_with :success

    end
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do
    it "succeeds when there are works" do
      Work.any?.must_equal true

      get works_path

      must_respond_with :success
    end

    it "succeeds when there are no works" do

      works = Work.all
      works.each { |work| work.destroy }

      #test precondition
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
              title: "Some Work",
              category: CATEGORIES.sample.singularize
            }

            # Test assumptions
            Work.new(work_data).must_be :valid?

            old_work_count = Work.count

            # Act
            post works_path params: { work: work_data }

            # Assert
            must_respond_with :redirect
            must_redirect_to work_path(Work.last)

            Work.count.must_equal old_work_count + 1
            Work.last.title.must_equal work_data[:title]
    end

    it "renders bad_request and does not update the DB for bogus data" do
      work_data = {
              title: "",
              category: CATEGORIES.sample.singularize
            }

            # Test assumptions
            Work.new(work_data).wont_be :valid?

            old_work_count = Work.count

            # Act
            post works_path params: { work: work_data }

            # Assert
            must_respond_with :bad_request

            Work.count.must_equal old_work_count

    end

    it "renders 400 bad_request for bogus categories" do
      work_data = {
              title: "Some Work",
              category: INVALID_CATEGORIES.sample.singularize
            }

            # Test assumptions
            Work.new(work_data).wont_be :valid?

            old_work_count = Work.count

            # Act
            post works_path params: { work: work_data }

            # Assert
            must_respond_with :bad_request

            Work.count.must_equal old_work_count
    end

  end

  describe "show" do
    it "succeeds for an extant work ID" do

      work = Work.first

      get work_path(work)

      must_respond_with :success

    end

    it "renders 404 not_found for a bogus work ID" do
      work = Work.last.id + 1

      get work_path(work)

      must_respond_with :missing

    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do
      work = Work.first

      get edit_work_path(work)

      must_respond_with :success
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
