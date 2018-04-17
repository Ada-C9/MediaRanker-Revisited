require 'test_helper'

describe WorksController do
  describe "root" do
    it "succeeds with all media types" do
      Work.best_albums.count.must_be :>, 0
      Work.best_books.count.must_be :>, 0
      Work.best_movies.count.must_be :>, 0
      get root_path
      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      Work.best_albums.destroy_all
      Work.best_books.count.must_be :>, 0
      Work.best_movies.count.must_be :>, 0
      get root_path
      must_respond_with :success
    end

    it "succeeds with no media" do
      Work.best_albums.destroy_all
      Work.best_books.destroy_all
      Work.best_movies.destroy_all
      get works_path
      must_respond_with :success
    end
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do
    it "succeeds when there are works" do
      Work.to_category_hash.count.must_be :>, 0
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
      work_data = { title: "Something cool",
      creator: "Ari",
      category: "album" }
      work_count = Work.count

      Work.new(work_data).must_be :valid?

      post works_path, params: { work: work_data}
      must_respond_with :redirect
      must_redirect_to work_path(Work.last.id)

      Work.count.must_equal work_count + 1
      Work.last.title.must_equal work_data[:title]
    end

    it "renders bad_request and does not update the DB for bogus data" do
      work_data = { title: nil,
      creator: nil,
      category: "album"
      }
      work_count = Work.count
      post works_path, params: {work: work_data}

      must_respond_with :bad_request
      Work.count.must_equal work_count
    end

    it "renders 400 bad_request for bogus categories" do
      work_data = { title: "breakfast",
      creator: "Ari",
      category: "bacon"
      }
      work_count = Work.count
      post works_path, params: {work: work_data}

      must_respond_with :bad_request
      Work.count.must_equal work_count
      Work.last.title.wont_equal work_data[:title]
    end

  end

  describe "show" do
    it "succeeds for an extant work ID" do
      get work_path(Work.first)
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
      get edit_work_path(Work.first)
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
      work_data = work.attributes
      work_data[:title] = 'another title'
      work.update_attributes(work_data)
      work.must_be :valid?

      patch work_path(work), params: {work: work_data}
      must_redirect_to work_path(work)
      work.reload
      Work.first.title.must_equal work_data[:title]
    end

    it "renders not_found for bogus data" do
      work = Work.first
      work_data = work.attributes
      work_data[:title] = ' '
      work.assign_attributes(work_data)
      work.wont_be :valid?

      patch work_path(work), params: {work: work_data}

      must_respond_with :not_found

      Work.first.title.wont_equal work_data[:title]
    end

    it "renders 404 not_found for a bogus work ID" do
      work_id = Work.last.id + 2
      patch work_path(work_id)
      must_respond_with :not_found
    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do
      work_id = Work.first.id
      work_count = Work.count

      delete work_path(work_id)
      must_respond_with :redirect
      must_redirect_to root_path
      Work.count.must_equal work_count - 1
      Work.find_by(id: work_id).must_be_nil
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      work_id = Work.last.id + 1
      work_count = Work.count

      delete work_path(work_id)
      must_respond_with :not_found
      Work.count.must_equal work_count
    end
  end

  describe "upvote" do

    it "redirects to the work page if no user is logged in" do
      login_user = nil
      vote = Vote.new(user: login_user, work: Work.first)

      work_id = Work.first.id
      post upvote_path(work_id)
      vote.wont_be :valid?

      must_respond_with :redirect
      must_redirect_to work_path

    end

    it "redirects to the work page after the user has logged out" do
      login_user = User.last
      post logout_path(login_user)
      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      login_user = User.last
      work = Work.last
      votes = work.vote_count

      post login_path, params: {username: login_user.username}
      post upvote_path(work)
      total_votes = work.vote_count

      must_respond_with :redirect
      must_redirect_to work_path(work)
      votes.must_equal total_votes
    end

    it "redirects to the work page if the user has already voted for that work" do
      login_user = User.last
      work = Work.last
      votes = work.vote_count

      post login_path, params: {username: login_user.username}
      post upvote_path(work)
      post upvote_path(Work.last)
      total_votes = work.vote_count

      must_respond_with :redirect
      must_redirect_to work_path(work)
      votes.must_equal total_votes
    end
  end
end
