require 'test_helper'

describe WorksController do
  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category
      Work.where(category: "album").count.must_be :>, 0
      Work.where(category: "movie").count.must_be :>, 0
      Work.where(category: "book").count.must_be :>, 0

      get root_path

      must_respond_with :success
    end



    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      Work.where(category: "book").destroy_all

      # Assumptions
      Work.where(category: "album").count.must_be :>, 0
      Work.where(category: "movie").count.must_be :>, 0
      Work.where(category: "book").must_be_empty

      get root_path

      must_respond_with :success

    end

    it "succeeds with no media" do
      Work.where(category: "book").destroy_all
      Work.where(category: "album").destroy_all
      Work.where(category: "movie").destroy_all

      # Assumptions
      Work.where(category: "album").must_be_empty
      Work.where(category: "movie").must_be_empty
      Work.where(category: "book").must_be_empty

      get root_path

      must_respond_with :success

    end
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do
    it "succeeds when there are works" do
      Work.count.must_be :>,0
      get works_path
      must_respond_with :success
    end

    it "succeeds when there are no works" do
      Work.destroy_all
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
        category: CATEGORIES.sample,
        title: "testing title "
      }

      Work.new(work_data).must_be :valid?

      old_count = Work.count

      post works_path, params: { work: work_data }

      must_respond_with :redirect
      Work.count.must_equal old_count + 1
    end

    it "renders bad_request and does not update the DB for bogus data" do

      work_data = {
        category: CATEGORIES.sample,
        title: ""
      }


      Work.new(work_data).wont_be :valid?
      old_count = Work.count

      post works_path, params: { work: work_data }

      must_respond_with :bad_request
      Work.count.must_equal old_count
    end



    it "renders 400 bad_request for bogus categories" do
      work_data = {
        category: INVALID_CATEGORIES.sample,
        title: "testing title",
      }
      old_count = Work.count


      Work.new(work_data).wont_be :valid?

      post works_path, params: { work: work_data }

      must_respond_with :bad_request
      Work.count.must_equal old_count
    end

  end

  describe "show" do
    it "succeeds for an extant work ID" do

      work_id = Work.first.id

      get work_path(work_id)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      work_id = Work.last.id + 1

      get work_path(work_id)

      must_respond_with :not_found
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do
      work_id = Work.first.id
      get edit_work_path(work_id)

      must_respond_with :success

    end

    it "renders 404 not_found for a bogus work ID" do
      work_id = Work.last.id + 1

      get edit_work_path(work_id)

      must_respond_with :not_found

    end
  end

  describe "update" do
    it "succeeds for valid data and an extant work ID" do

      work = Work.first
      work_data = {
        category: CATEGORIES.sample,
        title: "title edited",
      }

      work.assign_attributes(work_data)
      work.must_be :valid?

      # act
      patch work_path(work), params: {work: work_data}

      # assert
      must_respond_with :redirect

      work.reload
      work.title.must_equal work_data[:title]

    end

    it "renders not_found for bogus data" do
      work = Work.first
      work_data = {
        title: "",
        category: CATEGORIES.sample
      }

      # Assumptions
      work.assign_attributes(work_data)
      work.valid?.must_equal false

      patch work_path(work), params: { work: work_data }

      must_respond_with :not_found
      work.reload
      work.title.wont_equal work_data[:title]
    end

    it "renders 404 not_found for a bogus work ID" do
      work_id = Work.last.id + 1

      patch work_path(work_id)

      must_respond_with :not_found
    end

  end

  describe "destroy" do
    it "succeeds for an extant work ID" do
      #arrange
      work_id = Work.first.id
      old_work_count = Work.count

      #act
      delete work_path(work_id)

      #assert
      must_respond_with :redirect
      must_redirect_to root_path


      Work.count.must_equal old_work_count - 1
      Work.find_by(id: work_id).must_be_nil
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      work_id = Work.last.id + 1
      old_work_count = Work.count

      delete work_path(work_id)

      must_respond_with :not_found
      Work.count.must_equal old_work_count
    end
  end

  describe "upvote" do

    it "redirects to the work page if no user is logged in" do
      work = Work.first
      post upvote_path(work)

      must_respond_with :redirect
      must_redirect_to work_path(work)
    end

    it "redirects to the work page after the user has logged out" do

      work = Work.first
      old_count = work.votes.count

      post login_path, params: { username: User.first.username }
      post logout_path, params: { username: User.first.username }

      post upvote_path(work)

      must_respond_with :redirect
      must_redirect_to work_path(work)
      work.reload
      work.votes.count.must_equal old_count

    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      work = Work.first
      old_count = work.votes.count

      post login_path, params: { username: User.first.username }

      post upvote_path(work)

      must_respond_with :redirect
      must_redirect_to work_path(work)
      work.reload
      work.votes.count.must_equal old_count + 1
    end

    it "redirects to the work page if the user has already voted for that work" do
      user = User.find_by(username: "dan")
      work = user.votes.first.work
      vote_count = work.votes.count

      post login_path, params: { username: user.username}
      post upvote_path(work)

      must_respond_with :redirect
      must_redirect_to work_path(work)
      work.reload
      work.votes.count.must_equal vote_count

    end
  end
end
