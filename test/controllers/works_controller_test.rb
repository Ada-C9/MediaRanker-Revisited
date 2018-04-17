require 'test_helper'

describe WorksController do
  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category
      work = Work.find_by(category: "book")
      work.must_be :valid?
      work = Work.find_by(category: "movie")
      work.must_be :valid?
      work = Work.find_by(category: "album")
      work.must_be :valid?
      get root_path
      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      works = Work.where(category: "book")
      works.each do |work|
        work.destroy
      end
      Work.where(category: "book").must_be :empty?
      get root_path
      must_respond_with :success
    end

    it "succeeds with no media" do
      Work.destroy_all
      Work.count.must_equal 0
      get root_path
      must_respond_with :success
    end
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do
    it "succeeds when there are works" do
      # Assumption instead of Arrange
      # Check your assumption
      Work.count.must_be :>, 0

      # Act
      get works_path

      # Assert
      must_respond_with :success
    end

    it "succeeds when there are no works" do
      # Arrange
      Work.destroy_all

      # Act
      get works_path

      # Assert
      must_respond_with :success
    end
  end

  describe "new" do
    it " responds with success" do
      get new_work_path

      must_respond_with :success
    end
  end

  describe "create" do
    it "creates a work with valid data for a real category" do
      # Arrange
      work_data = {
        title: 'controller test work',
        category: 'movie',
        creator: 'test creator'
      }
      work = Work.new(work_data)
      old_work_count = Work.count

      # Assumption
      work.must_be :valid?

      # Act
      post works_path, params: { work: work_data }

      # Assert
      must_respond_with :redirect
      must_redirect_to work_path(Work.last)

      Work.count.must_equal old_work_count + 1
      Work.last.category.must_equal work_data[:category]
    end

    it "renders bad_request and does not update the DB for bogus data" do
      # Arrange
      work_data = {
        title: "",
        creator: ""
      }
      old_work_count = Work.count

      # Assumption
      Work.new(work_data).wont_be :valid?

      # Act
      post works_path, params: { book: work_data }

      # Assert
      must_respond_with :bad_request
      Work.count.must_equal old_work_count
    end

    it "renders 400 bad_request for bogus categories" do
      # Arrange
      work_data = {
        category: "luxi",
      }
      old_work_count = Work.count

      # Assumption
      Work.new(work_data).wont_be :valid?

      # Act
      post works_path, params: { book: work_data }

      # Assert
      must_respond_with :bad_request
      Work.count.must_equal old_work_count
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
      # Arrange
      work = Work.first
      work_data = work.attributes
      work_data[:title] = 'some updated title'

      # Assumption
      work.assign_attributes(work_data)
      work.must_be :valid?

      # Act
      patch work_path(work), params: { work: work_data }

      # Assert
      must_respond_with :redirect
      must_redirect_to work_path(work)

      Work.first.title.must_equal work_data[:title]
    end

    it "renders not_found for bogus data" do
      # Arrange
      work = Work.first
      work_data = work.attributes
      work_data[:title] = ""

      # Assumption
      work.assign_attributes(work_data)
      work.wont_be :valid?

      # Act
      patch work_path(work), params: { work: work_data }

      # Assert
      must_respond_with :not_found

      Work.first.title.wont_equal work_data[:title]
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
      old_work_count = Work.count

      # Act
      delete work_path(work_id)

      # Assert
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
      old_work_count = work.vote_count

      # Act
      post upvote_path(work)

      # Assert
      must_respond_with :redirect
      must_redirect_to work_path(work)

      work.vote_count.must_equal old_work_count
    end

    it "redirects to the work page after the user has logged out" do
      user = User.first
      post login_path, params: {username: user.username}
      post logout_path, params: {username: user.id}

      work = Work.first
      old_work_count = work.vote_count

      # Act
      post upvote_path(work)

      # Assert
      must_respond_with :redirect
      must_redirect_to work_path(work)

      work.reload
      work.vote_count.must_equal old_work_count
    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      user = User.first
      post login_path, params: {username: user.username}

      work = Work.first
      old_work_count = work.vote_count

      # Act
      post upvote_path(work)

      # Assert
      must_respond_with :redirect
      must_redirect_to work_path(work)

      work.reload
      work.vote_count.must_equal old_work_count + 1
    end

    it "redirects to the work page if the user has already voted for that work" do
      user = User.first
      post login_path, params: {username: user.username}

      work = Work.first
      old_work_count = work.vote_count

      # Act
      post upvote_path(work)

      # Assert
      must_respond_with :redirect
      must_redirect_to work_path(work)

      work.reload
      work.vote_count.must_equal old_work_count + 1

      post upvote_path(work)
      work.reload
      work.vote_count.must_equal old_work_count + 1
    end
  end
end
