require 'test_helper'
require 'pry'

describe WorksController do

  describe 'logged in user' do

    describe "root" do
      it "succeeds with all media types" do
        # Precondition: there is at least one media of each category
login(User.first)
        works = Work.where(category: "work")
        movies = Work.where(category: "movie")
        albums = Work.where(category: "album")

        get root_path
        must_respond_with :success
      end

      it "succeeds with one media type absent" do
        # Precondition: there is at least one media in two of the categories
        login(User.first)
        works = Work.where(category: "work")
        albums = Work.where(category: "album")

        get root_path
        must_respond_with :success
      end

      it "succeeds with no media" do
        login(User.first)
        get root_path
        must_respond_with :success
      end
    end

    CATEGORIES = %w(albums books movies)
    INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

    describe "index" do
      it "succeeds when there are works" do
        login(User.first)
        Work.count.must_be :>, 0
        #act
        get works_path
        #assert
        must_respond_with :success
      end

      it "succeeds when there are no works" do
        login(User.first)
        Work.destroy_all
        Work.all.length.must_equal 0
        get works_path

        must_respond_with :success
      end
    end

    describe "new" do
      it "succeeds" do
        login(User.first)
        get new_work_path
        must_respond_with :success
      end
    end

    describe "create" do
      it "creates a work with valid data for a real category" do
        login(User.first)
        work_data = {
          title: 'controller test work',
          creator: "testtest",
          publication_year: 2003,
          category: "movie"
        }
        old_work_count = Work.count
        #Assumptions
        Work.new(work_data).must_be :valid?

        #Act
        post works_path, params: { work: work_data }

        #assert
        #check http response
        must_redirect_to work_path(Work.last)
        #check database
        Work.count.must_equal old_work_count + 1
        Work.last.title.must_equal work_data[:title]
      end

      it "renders bad_request and does not update the DB for bogus data" do
        login(User.first)
        old_work_count = Work.count
        work_data = {
          title: nil,
          category: "album"
        }
        Work.new(work_data).wont_be :valid?
        #act
        post works_path, params: {work: work_data}

        must_respond_with :bad_request
        Work.count.must_equal old_work_count
      end

      it "renders 400 bad_request for bogus categories" do
        login(User.first)
        old_work_count = Work.count
        work_data = {
          title: nil,
          category: "cotton candy"
        }
        Work.new(work_data).wont_be :valid?
        #act
        post works_path, params: {work: work_data}

        must_respond_with :bad_request
        Work.count.must_equal old_work_count
      end

    end

    describe "show" do
      it "succeeds for an extant work ID" do
        login(User.first)
        get work_path(Work.first)
        must_respond_with :success
      end

      it "renders 404 not_found for a bogus work ID" do
        login(User.first)
        work_id = Work.last.id + 1

        get work_path(work_id)
        must_respond_with :not_found
      end
    end

    describe "edit" do
      it "succeeds for an extant work ID" do
        login(User.first)
        get edit_work_path(Work.first)
        must_respond_with :success
      end

      it "renders 404 not_found for a bogus work ID" do
        login(User.first)
        get edit_work_path(Work.last.id + 1)
        must_respond_with :not_found
      end
    end

    describe "update" do
      it "succeeds for valid data and an extant work ID" do
        login(User.first)
        work = Work.first
        work_data = work.attributes
        work_data[:title] = "some updated title"

        work.assign_attributes(work_data)
        work.must_be :valid?

        patch work_path(work), params: {work: work_data}

        must_redirect_to work_path(work)
        work.reload
        work.title.must_equal work_data[:title]

      end

      it "renders not_found for bogus data" do
        login(User.first)
        work = Work.first
        work_data = work.attributes
        work_data[:title] = ""

        work.assign_attributes(work_data)
        work.wont_be :valid?

        patch work_path(work.id), params: {work: work_data}

        must_respond_with :not_found
        work.reload
        work.title.wont_equal work_data[:title]
      end

      it "renders 404 not_found for a bogus work ID" do
        login(User.first)
        work_id = Work.last.id + 1

        patch work_path(work_id)

        must_respond_with :not_found
      end
    end

    describe "destroy" do
      it "succeeds for an extant work ID" do
        login(User.first)
        work_id = Work.first.id
        old_count = Work.count
        delete work_path(work_id)
        # must_respond_with :success

        must_redirect_to root_path
        Work.count.must_equal old_count - 1

        Work.find_by(id: work_id).must_be_nil
      end

      it "renders 404 not_found and does not update the DB for a bogus work ID" do
        login(User.first)
        work_id = Work.last.id + 1

        patch work_path(work_id)

        must_respond_with :not_found

      end
    end

    describe "upvote" do

      it "succeeds for a logged-in user and a fresh user-vote pair" do
        login(User.first)
        Vote.destroy_all

        work = Work.first
        vote_count = work.vote_count

        post upvote_path(work.id)
        work.vote_count.must_equal vote_count + 1
      end

      it "redirects to the work page if the user has already voted for that work" do
        login(User.first)
        Vote.destroy_all
        work = Work.first

        post upvote_path(work.id)
        vote_count = work.vote_count
        post upvote_path(work)
        must_respond_with :redirect
        work.vote_count.must_equal vote_count
      end
    end
  end

  describe 'guest user' do
    it 'rejects requests for new book form' do
      get new_work_path
      must_respond_with :redirect
    end

    it 'rejects requests to create a book' do
      work_data = {
        title: 'controller test work',
        creator: "testtest",
        publication_year: 2003,
        category: "movie"
      }
      old_work_count = Work.count
      #Assumptions
      Work.new(work_data).must_be :valid?

      #Act
      post works_path, params: { work: work_data }

      #assert
      #check http response
      must_respond_with :redirect
      #check database
      Work.count.must_equal old_work_count
    end

    it 'rejects requests for the edit form' do
      get edit_work_path(Work.first)
      must_respond_with :redirect
    end

    it 'rejects requests to update a book' do
      work = Work.first
      work_data = work.attributes
      work_data[:title] = "some updated title"

      work.assign_attributes(work_data)
      work.must_be :valid?

      patch work_path(work), params: {work: work_data}

      must_respond_with :redirect
    end

    it 'rejects requests to destroy a book' do
      work_id = Work.first.id
      old_count = Work.count
      delete work_path(work_id)
      # must_respond_with :success
      #
      # must_redirect_to root_path
      must_respond_with :redirect
      Work.count.must_equal old_count
    end
  end
end
