require 'test_helper'

describe WorksController do
  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category
      album = Work.create(title: "Best Album", category: "album")
      book = Work.create(title: "Best Book", category: "book")
      movie = Work.create(title: "Best Movie", category: "movie")

      get root_path
      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      album = Work.create(title: "Best Album", category: "album")
      book = Work.create(title: "Best Book", category: "book")

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
      work_data = { title: "Valid Work", category: "album"}

      old_work_count = Work.count

      Work.new(work_data).must_be :valid?

      post works_path, params: { work: work_data }
      must_respond_with :redirect
      must_redirect_to work_path(Work.last)
    end

    it "renders bad_request and does not update the DB for bogus data" do
      old_work_count = Work.count

      work_data = { title: "", category: "not a category" }
      Work.new(work_data).wont_be :valid?

      post works_path, params: { work: work_data }
      must_respond_with :bad_request
      Work.count.must_equal old_work_count
    end

    it "renders 400 bad_request for bogus categories" do
      old_work_count = Work.count

      work_data = { title: "A Title", category: "not a category" }
      Work.new(work_data).wont_be :valid?

      post works_path, params: { work: work_data }
      must_respond_with :bad_request
      must_respond_with 400
      Work.count.must_equal old_work_count
    end

  end

  describe "show" do
    it "succeeds for an extant work ID" do
      votes = Work.first.votes.order(created_at: :desc)

      get work_path(Work.first)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      bogus_work_id = Work.last.id + 1
      get work_path(bogus_work_id)
      must_respond_with 404
      must_respond_with :not_found
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do
      work_id = Work.first
      get edit_work_path(work_id)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      bogus_work_id = Work.last.id + 1
      get edit_work_path(bogus_work_id)
      must_respond_with :not_found
      must_respond_with 404
    end
  end

  describe "update" do
    it "succeeds for valid data and an extant work ID" do
      work = Work.first
      work_data = Work.first.attributes
      work_data[:title] = "New Valid Title"

      patch work_path(work.id), params: { work: work_data }
      must_respond_with :redirect
      must_redirect_to work_path(work)

      work.reload

      work.title.must_equal work_data[:title]
    end

    it "renders not_found for bogus data" do
      work = Work.first
      work_data = Work.first.attributes
      work_data[:title] = ""

      patch work_path(work.id), params: { work: work_data }
      must_respond_with :not_found

      work.reload

      work.title.wont_equal work_data[:title]
    end

    it "renders 404 not_found for a bogus work ID" do
      work_id = Work.last.id + 1
      patch work_path(work_id)
      must_respond_with :not_found
      must_respond_with 404
    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do
      work_id = Work.first.id
      old_count = Work.count

      delete work_path(work_id)

      must_respond_with :redirect
      must_redirect_to root_path

      Work.count.must_equal old_count - 1
      Work.find_by(id: work_id).must_be_nil
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      work_id = Work.last.id + 1
      old_count = Work.count
      delete work_path(work_id)

      must_respond_with :not_found
      must_respond_with 404
      Work.count.must_equal old_count
    end
  end

  describe "upvote" do

    it "redirects to the work page if no user is logged in" do
      user = User.first
      user_params = user.attributes
      username = user_params[:username]
      post login_path, params: { session: {user_id: user.id, username: username}}

      puts flash[:result_text]
      puts flash.now[:messages]

    end

    it "redirects to the work page after the user has logged out" do

    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do

    end

    it "redirects to the work page if the user has already voted for that work" do
      User.count.must_be :>, 0
      user = User.first

      post login_path, params: { session: {user_id: user.id}}

      Work.count.must_be :>, 0
      work = Work.first

      first_vote = Vote.new(user_id: session[:user_id], work_id: work.id)
      first_vote.save
      post upvote_path(work.id)
      second_vote = Vote.new(user_id: session[:user_id], work_id: work.id)
      second_vote.save
      post upvote_path(work.id)
      second_vote.wont_be :valid?

      must_redirect_to work_path(work.id)

    end
  end
end
