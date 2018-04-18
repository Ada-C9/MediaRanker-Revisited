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
      get work_path(Work.first)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      bogus_work_id = Work.last.id + 1

      get edit_work_path(bogus_work_id)

      must_respond_with :not_found
    end
  end

  # REVIEW: HAVE CHARLES WALK ME THROUGH THE BELOW TEST
  describe "update" do
    it "succeeds for valid data and an extant work ID" do
      work = works(:album)
      work_data = work.attributes
      work_data[:title] = "random new title"

      work.assign_attributes(work_data)
      work.must_be :valid?

      patch work_path(work), params: { work: work_data }

      must_redirect_to work_path(work)

      work.reload
      work.title.must_equal work_data[:title]
    end

    it "renders bad_request for bogus data" do
      work = Work.first
      work_data = work.attributes
      work_data[:title] = " "

      work.assign_attributes(work_data)
      work.wont_be :valid?

      patch work_path(work), params: { work: work_data }

      must_respond_with :bad_request

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
      # Arrange
      work_id = Work.first.id
      start_count = Work.count

      # Act
      delete work_path(work_id)

      # Assert
      must_respond_with :redirect
      must_redirect_to root_path

      Work.count.must_equal start_count - 1
      Work.find_by(id: work_id).must_be_nil
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      work_id = Work.last.id + 1
      start_count = Work.count

      delete work_path(work_id)

      must_respond_with :not_found
      Work.count.must_equal start_count
    end
  end

  describe "upvote" do

    it "redirects to the work page if no user is logged in" do
      work_id = Work.first.id

      post upvote_path(work_id)
      must_respond_with :redirect
    end

    it "redirects to the work page after the user has logged out" do
      work_id = Work.first.id

      post logout_path

      must_respond_with :redirect
    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      test_work = Work.first

      start_vote_count = test_work.votes.count

      post login_path, params: { username: User.first.username}
      must_respond_with :redirect

      post upvote_path(test_work.id)
      must_respond_with :redirect

      test_work.votes.count.must_equal start_vote_count + 1
    end

    it 'adds a vote to the user\'s votes list' do
      test_work = Work.first

      test_user = User.first

      start_vote_count = test_user.votes.count

      post login_path, params: { username: test_user.username}
      must_respond_with :redirect

      post upvote_path(test_work.id)
      must_respond_with :redirect

      test_user.votes.count.must_equal start_vote_count + 1
    end

    it "redirects to the work page if the user has already voted for that work" do
      test_work = Work.last

      start_vote_count = Vote.count

      post login_path, params: { username: User.first.username}
      must_respond_with :redirect

      post upvote_path(test_work.id)
      must_respond_with :redirect

      Vote.count.must_equal start_vote_count
    end
  end
end

# TODO: GO BACK AND UPDATE USING FIXTURES
