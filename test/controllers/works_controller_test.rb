require 'test_helper'

# Works controller responsible for:


describe WorksController do
  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category
      # Arrange
      Work.where(category: "album").count.must_be :>, 0
      Work.where(category: "book").count.must_be :>, 0
      Work.where(category: "movie").count.must_be :>, 0

      # #Act
      get root_path
      # # Assert
      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      # Arrange
      Work.where(category: "album").count.must_be :>, 0
      Work.where(category: "book").count.must_be :>, 0
      # must delete all movies so that none exit in that category
      Work.where(category: "movie").destroy_all

      Work.where(category: "movie").count.must_be :==, 0

      # Act
      get root_path
      # Assert
      must_respond_with :success
    end

    it "succeeds with no media" do
      # Arrange
      Work.destroy_all
      Work.all.length.must_equal 0
      # Act
      get works_path
      # Assert
      must_respond_with :success
    end
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do
    it "succeeds when there are works" do
      # get works
      Work.all.count.must_be :>, 0
      get works_path
      must_respond_with :success
    end

    it "succeeds when there are no works" do
      # Arrange
      Work.destroy_all
      Work.all.length.must_equal 0
      # Act
      get works_path
      # Assert
      must_respond_with :success
    end
  end

  describe "new" do
    it "succeeds" do
      # Arrange & Act
      get new_work_path
      # Assert
      must_respond_with :success
    end
  end

  describe "create" do
    it "creates a work with valid data for a real category" do
      # Arrange-store data and test it
      new_work = { title: 'Island Under The Sea',
        creator:'You',
        description: 'Chile',
        publication_year: 1999-11-01,
        category: 'book'
      }

      old_work_count = Work.count

      Work.new(new_work).must_be :valid?

      # Act
      post works_path, params: { work: new_work }
      # Assert

      # Assert
      must_respond_with :redirect
      must_redirect_to work_path(Work.last)

      Work.count.must_equal old_work_count + 1
      Work.last.title.must_equal new_work[:title]
    end

    it "renders bad_request and does not update the DB for bogus data" do
      # Arrange
      bad = {
        creator:'You',
        description: 'Chile',
        publication_year: 1999-11-01,
        category: 'book'
      }
      old_work_count = Work.count

      Work.new(bad).wont_be :valid?
      # Act
      post works_path, params: { work: bad }
      # Assert
      Work.count.must_equal old_work_count
      must_respond_with :bad_request
    end

    it "renders 400 bad_request for bogus categories" do #for every category
      # Arrange
      bad = {
        creator:'You',
        description: 'Chile',
        publication_year: 1999-11-01,
        category: 'book'
      }
      old_work_count = Work.count

      Work.new(bad).wont_be :valid?
      # Act
      post works_path, params: { work: bad }
      # Assert
      Work.count.must_equal old_work_count
      must_respond_with :bad_request
    end

  end

  describe "show" do
    it "succeeds for an extant work ID" do
      # Arrange & Act - get path
      get work_path(Work.first)
      # Assert - :success
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      # Arrange
      work_id = Work.last.id + 1
      # Act - get path
      get work_path(work_id)
      # Assert
      must_respond_with :not_found
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do
      # Arrange & Act
      get edit_work_path(Work.first)
      # Assert
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      work_id = Work.last.id + 1
      # Act - get path
      get edit_work_path(work_id)
      # Assert
      must_respond_with :not_found
    end
  end

  # Update
  # What should happen if the controller executes an update of something with valid data? with invalid data?
  # Delete
  # What should happen if the controller tries to delete an ID of a model that exists in the DB? that doesn't exist in the DB?

  describe "update" do
    it "succeeds for valid data and an extant work ID" do
      # Arrange
      work = Work.first
      work_data = work.attributes
      work_data[:title] = "Deep Sleeper"

      # Assumptions
      work.assign_attributes(work_data)
      work.must_be :valid?

      # Act - send to instance in db w/ the right parameters
      patch work_path(work), params: { work: work_data }

      # Assert
      must_redirect_to work_path(work)
      work.reload
      work.title.must_equal work_data[:title]

    end

    it "renders bad_request for bogus data" do
      # Arrange - use a current entry & update w/ bad data??
      work = Work.first
      work_data = work.attributes
      work_data[:title] = ""

      # Assumptions
      work.assign_attributes(work_data)
      work.wont_be :valid?
      # Act
      patch work_path(work), params: { work: work_data }
      # Assert
      must_respond_with :bad_request

    end

    it "renders 404 not_found for a bogus work ID" do
      # Arrange -
      work_id = Work.last.id + 1
      # Act
      patch work_path(work_id)
      # Assert
      must_respond_with :not_found
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
      # Arrange -
      work = Work.last
      # Act - path
      proc {
        post upvote_path(work)
      }.must_change 'Vote.count', 0

      # Assert
      must_redirect_to work_path(work)

    end

    it "redirects to the work page after the user has voted" do
      # Arrange
      work_data = Work.first.attributes
      work_data[:id] = nil
      work_data[:title] = "New Awesome Work"

      work = Work.create(work_data)

      user = User.first

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))

      get auth_callback_path(:github)

      must_redirect_to root_path

      session[:user_id].must_equal user.id

      # Act
      proc {
        post upvote_path(work)
      }.must_change 'Vote.count', 1

      # Assert
      must_redirect_to work_path(work)

    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      # Arrange - user can vote if they haven't voted for work before
      work = Work.first
      user = User.first

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))

      get auth_callback_path(:github)
      # Act - check assumptions?
      proc {
        post upvote_path(work)
      }.must_change 'Vote.count', 1

      # Assert
      session[:user_id].must_equal user.id

    end

    it "redirects to the work page if the user has already voted for that work" do

    end
  end
end
