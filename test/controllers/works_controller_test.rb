require 'test_helper'

describe WorksController do
  describe "root" do
    it "succeeds with all media types" do
      media_types = ['album', 'movie', 'book']
      media_types.each do |category|
        work = Work.new(title: 'test', category: category)
        work.save
      end

      get root_path
      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      Work.where(category: "book").destroy_all
      media_types = ['album', 'movie']
      media_types.each do |category|
        work = Work.new(title: 'test', category: category)
        work.save
      end

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
      media_types = ['album', 'movie', 'book']
      media_types.each do |category|
        work = Work.new(title: 'test', category: category)
        work.save
      end

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
      media_types = ['album', 'movie', 'book']
      media_types.each do |category|
        work = Work.create(title: 'test', category: category)
        puts work.id
        post works_path(work)
        must_respond_with :redirect
        # must_respond_with :redirect
        # must_redirect_to work_path(work)
      end

      puts "___________________________________________"
    end

    it "renders bad_request and does not update the DB for bogus data" do

    end

    it "renders 400 bad_request for bogus categories" do

    end

  end
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
