require 'test_helper'
require 'pry'

describe WorksController do
  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category
      categories = Work.all.map { |work| work.category.pluralize }
      (categories - CATEGORIES).must_be :empty?
      get root_path
      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      works = Work.all
      old_works_count = Work.count
      movies_count = 0
      works.each do |work|
        if work.category == 'movie'
          works.delete(work)
          movies_count += 1
        end
      end
      Work.count.must_equal old_works_count - movies_count
      get root_path
      must_respond_with :success
    end

    it "succeeds with no media" do
      Work.delete_all
      Work.count.must_equal 0
      get root_path
      must_respond_with :success
    end
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do
    it "succeeds when there are works" do
      Work.all.count.must_be :>, 0
      get works_path
      must_respond_with :success
    end

    it "succeeds when there are no works" do
      Work.delete_all
      Work.count.must_equal 0
      get works_path
      must_respond_with :success
    end
  end

  describe "new" do
    it "succeeds" do
      work = Work.first
      get new_work_path, params: { work: work }
      must_respond_with :success
    end
  end

  describe "create" do
    it "creates a work with valid data for a real category" do
      old_works_count = Work.all.count
      work_data = {
        title: 'Gladiator',
        category: 'movie'
      }

      Work.new(work_data).must_be :valid?

      post works_path, params: { work: work_data }
      must_respond_with :redirect
      must_redirect_to work_path(Work.last)

      Work.count.must_equal old_works_count + 1
      CATEGORIES.must_include Work.last.category.pluralize
      INVALID_CATEGORIES.wont_include Work.last.category
    end

    it "renders bad_request and does not update the DB for bogus data" do
      old_works_count = Work.all.count
      work_data = {
        category: 'movie'
      }

      Work.new(work_data).wont_be :valid?

      post works_path, params: { work: work_data }
      must_respond_with :bad_request

      Work.count.must_equal old_works_count
    end

    it "renders 400 bad_request for bogus categories" do
      old_works_count = Work.all.count
      work_data = {
        title: 'Gladiator',
        category: INVALID_CATEGORIES.sample
      }

      Work.new(work_data).wont_be :valid?

      post works_path, params: { work: work_data }
      must_respond_with :bad_request

      Work.count.must_equal old_works_count
    end

  end

  describe "show" do
    it "succeeds for an extant work ID" do
      work = Work.last
      get work_path(work)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      id = Work.last.id + 1
      get work_path(id)
      must_respond_with :not_found
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do
      work = Work.last

      get work_path(work)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      id = Work.last.id + 1

      get work_path(id)

      must_respond_with :not_found
    end
  end

  describe "update" do
    it "succeeds for valid data and an extant work ID" do
      old_works_count = Work.count
      work = Work.last
      work_data = {
        title: 'Gladiator',
        category: 'movie',
        description: 'testing update action'
      }

      patch work_path(work), params: { work: work_data }

      must_respond_with :redirect
      must_redirect_to work_path(work)
      work.reload
      work.title.must_equal work_data[:title]
      work.category.must_equal work_data[:category]
      work.description.must_equal work_data[:description]
      Work.count.must_equal old_works_count
    end

    it "renders bad_request for bogus data" do
      old_works_count = Work.count
      work = Work.last
      work_data = {
        title: '',
        category: 'movie',
        description: 'testing update action'
      }

      patch work_path(work), params: { work: work_data }

      must_respond_with :bad_request
      work.reload
      work.title.wont_equal work_data[:title]
      Work.count.must_equal old_works_count
    end

    it "renders bad_request for a bogus category" do
      old_works_count = Work.count
      work = Work.last
      work_data = {
        title: 'Gladiator',
        category: INVALID_CATEGORIES.sample,
        description: 'testing update action'
      }

      patch work_path(work), params: { work: work_data }

      must_respond_with :bad_request
      work.reload
      work.category.wont_equal work_data[:category]
      Work.count.must_equal old_works_count
    end

    it "renders 404 not_found for a bogus work ID" do
      id = Work.last.id + 1
      work_data = {
        title: 'Gladiator',
        category: 'movie',
        description: 'testing update action'
      }

      patch work_path(id), params: { work: work_data }

      must_respond_with :not_found
    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do
      old_works_count = Work.count
      work = Work.last

      delete work_path(work)

      must_respond_with :redirect
      must_redirect_to root_path
      Work.count.must_equal old_works_count - 1
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      old_works_count = Work.count
      id = Work.last.id + 1

      delete work_path(id)

      must_respond_with :not_found
      Work.count.
      must_equal old_works_count
    end
  end

  describe "upvote" do

    it "redirects to the work page if no user is logged in" do
      work = Work.last
      votes_before = work.votes.count

      post upvote_path(work)

      work.reload
      must_respond_with :redirect
      must_redirect_to work_path(work)
      work.votes.count.must_equal votes_before
    end

    it "redirects to the work page after the user has logged out" do
      work = Work.last
      votes_before = work.votes.count
      user = User.last

      login(user)
      post logout_path

      post upvote_path(work)

      work.reload
      must_respond_with :redirect
      must_redirect_to work_path(work)
      work.votes.count.must_equal votes_before
    end

    describe 'upvotes from a logged-in user' do
      before do
        @work = Work.last
        @votes_before = @work.votes.count
        @user = User.new(username: 'Thor Odinson', uid: 3, email: 'thor@hammer.asgard', provider: 'github')
        @user.must_be :valid?
        @user.save

        login(@user)

        post upvote_path(@work)
      end

      it "succeeds for a logged-in user and a fresh user-vote pair" do
        @work.reload
        must_respond_with :redirect
        must_redirect_to work_path(@work)
        @work.votes.count.must_equal @votes_before + 1
      end

      it "redirects to the work page if the user has already voted for that work" do
        @work.reload
        votes_after_first_vote = @work.votes.count
        post upvote_path(@work)
        @work.reload
        must_respond_with :redirect
        must_redirect_to work_path(@work)
        @work.votes.count.must_equal votes_after_first_vote
      end

    end # logged-in user

  end # upvote

end # WorksController
