require 'test_helper'

describe WorksController do
  describe "root" do
    it "succeeds with all media types" do

      works << Work.find_by_category("album")
      works << Work.find_by_category("book")
      works << Work.find_by_category("movie")
      works.include?(nil).must_equal false

      get root_path
      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      Work.find_by_category("album").nil?.must_equal false
      Work.find_by_category("book").nil?.must_equal false
      Work.destroy_all(category: "movie")
      Work.find_by_category("movie").nil?.must_equal true

      get root_path
      must_respond_with :success
    end

    it "succeeds with no media" do
      Work.destroy_all
      Work.all.count.must_equal 0

      get root_path
      must_respond_with :success
    end
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do
    it "succeeds when there are works" do

    end

    it "succeeds when there are no works" do
      Work.destroy_all
      Work.all.count.must_equal 0

      get works_path
      must_respond_with :success
    end
  end
  #
  # describe "new" do
  #   it "succeeds" do
  #
  #   end
  # end
  #
  # describe "create" do
  #   it "creates a work with valid data for a real category" do
  #
  #   end
  #
  #   it "renders bad_request and does not update the DB for bogus data" do
  #
  #   end
  #
  #   it "renders 400 bad_request for bogus categories" do
  #
  #   end
  #
  # end
  #
  # describe "show" do
  #   it "succeeds for an extant work ID" do
  #
  #   end
  #
  #   it "renders 404 not_found for a bogus work ID" do
  #
  #   end
  # end
  #
  # describe "edit" do
  #   it "succeeds for an extant work ID" do
  #
  #   end
  #
  #   it "renders 404 not_found for a bogus work ID" do
  #
  #   end
  # end
  #
  # describe "update" do
  #   it "succeeds for valid data and an extant work ID" do
  #
  #   end
  #
  #   it "renders bad_request for bogus data" do
  #
  #   end
  #
  #   it "renders 404 not_found for a bogus work ID" do
  #
  #   end
  # end
  #
  # describe "destroy" do
  #   it "succeeds for an extant work ID" do
  #
  #   end
  #
  #   it "renders 404 not_found and does not update the DB for a bogus work ID" do
  #
  #   end
  # end
  #
  # describe "upvote" do
  #
  #   it "redirects to the work page if no user is logged in" do
  #
  #   end
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
  # end
end
