require 'test_helper'

describe WorksController do
  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category

      #check precondition
      categories = %w(book album movie)

      categories.each do |category|
        work = Work.find_by(category: category)
        work.must_be :valid?
      end

      get root_path

      must_respond_with :success

    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories

      work_to_delete = Work.where(category: "album")

      work_to_delete.each do |work|
        work.destroy
      end

      #check precondition

      Work.where(category: "album").must_be :empty?

      get root_path

      must_respond_with :success

    end

    it "succeeds with no media" do

      works = Work.all
      works.each { |work| work.destroy }

      #test precondition
      Work.count.must_equal 0

      get root_path

      must_respond_with :success

    end
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]


  describe "index" do
    it "succeeds when there are works" do
      user = User.first
      login(user)

      Work.any?.must_equal true

      get works_path

      must_respond_with :success
    end

    it "succeeds when there are no works" do
      user = User.first
      login(user)

      works = Work.all
      works.each { |work| work.destroy }

      #test precondition
      Work.count.must_equal 0

      get works_path

      must_respond_with :success

    end
  end
  describe "with users" do
    before do
      user = User.first
      login(user)
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
          title: "Some Work",
          category: CATEGORIES.sample.singularize
        }

        # Test assumptions
        Work.new(work_data).must_be :valid?

        old_work_count = Work.count

        # Act
        post works_path params: { work: work_data }

        # Assert
        must_respond_with :redirect
        must_redirect_to work_path(Work.last)

        Work.count.must_equal old_work_count + 1
        Work.last.title.must_equal work_data[:title]
      end

      it "renders bad_request and does not update the DB for bogus data" do
        work_data = {
          title: "",
          category: CATEGORIES.sample.singularize
        }

        # Test assumptions
        Work.new(work_data).wont_be :valid?

        old_work_count = Work.count

        # Act
        post works_path params: { work: work_data }

        # Assert
        must_respond_with :bad_request

        Work.count.must_equal old_work_count

      end

      it "renders 400 bad_request for bogus categories" do
        work_data = {
          title: "Some Work",
          category: INVALID_CATEGORIES.sample.singularize
        }

        # Test assumptions
        Work.new(work_data).wont_be :valid?

        old_work_count = Work.count

        # Act
        post works_path params: { work: work_data }

        # Assert
        must_respond_with :bad_request

        Work.count.must_equal old_work_count
      end

    end

    describe "show" do
      it "succeeds for an extant work ID" do

        work = Work.first

        get work_path(work)

        must_respond_with :success

      end

      it "renders 404 not_found for a bogus work ID" do
        work = Work.last.id + 1

        get work_path(work)

        must_respond_with :missing

      end
    end

    describe "edit" do
      it "succeeds for an extant work ID" do
        user = users(:dan)
        login(user)
        work = Work.first

        get edit_work_path(work)

        must_respond_with :success
      end

      it "renders 404 not_found for a bogus work ID" do
        work = Work.first.id + 1

        get edit_work_path(work)

        must_respond_with :missing

      end
    end

    describe "update" do
      it "succeeds for valid data and an extant work ID" do
        work = Work.first

        work_data = work.attributes
        work_data[:title] = "Updated Title"

        work.assign_attributes(work_data)
        work.must_be :valid?

        patch work_path(work), params: {work: work_data}

        must_respond_with :redirect
        must_redirect_to work_path(work)
        work.reload

        work.title.must_equal work_data[:title]
      end

      it "renders bad_request for bogus data" do

        work = Work.first

        work_data = work.attributes
        work_data[:category] = INVALID_CATEGORIES.sample.singularize
        work_data[:title] = "An updated title"

        work.assign_attributes(work_data)
        work.wont_be :valid?

        patch work_path(work), params: {work: work_data}

        must_respond_with :bad_request
        work.reload

        work.title.wont_equal work_data[:title]


      end

      it "renders 404 not_found for a bogus work ID" do
        work_id = Work.first.id + 1
        work_data = {
          title: "Updated Book Title"
        }

        patch work_path(work_id), params: {work: work_data}

        must_respond_with :missing
      end
    end

    describe "destroy" do
      it "succeeds for an extant work ID" do
        work = Work.first

        old_work_count = Work.count

        delete work_path(work)

        must_respond_with :found
        # Work.count.must_equal old_work_count - 1
        # Work.find_by(id: work.id).must_be_nil
      end

      it "renders 404 not_found and does not update the DB for a bogus work ID" do

      end
    end
  end

  describe "upvote" do

    it "redirects to the work page if no user is logged in" do

      work = Work.first

      post upvote_path(work)

      must_redirect_to root_path
    end

    it "redirects to the work page after the user has logged out" do

      work = Work.first
      user = User.first

      login(user)
      must_respond_with :found

      post logout_path(user)
      must_respond_with :found

      original_vote = work.vote_count
      post upvote_path(work)

      must_redirect_to root_path
      Work.first.vote_count.must_equal original_vote

    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      user = User.first
      work = Work.first
      login(user)

      old_vote_count = work.vote_count

      post upvote_path(work)

      must_respond_with :found
      work.reload

      work.ranking_users.must_include user
      work.vote_count.must_equal old_vote_count + 1


    end

    it "redirects to the work page if the user has already voted for that work" do
      user = User.first
      work = Work.first

      login(user)
      old_vote_count = work.vote_count

      post upvote_path(work), params: {user_id: user.id}

      work.reload
      new_vote_count = work.vote_count

      must_respond_with :found
      work.ranking_users.must_include user


      post upvote_path(work), params: {user_id: user.id}
      must_redirect_to work_path(work)

      work.reload
      work.vote_count.must_equal new_vote_count
    end
  end
end
