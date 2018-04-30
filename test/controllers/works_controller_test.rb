require 'test_helper'

describe WorksController do
  describe "root" do
    describe "logged in user" do
      before do
        login(User.first)
      end

      it "succeeds with all media types" do
        works = Work.to_category_hash
        ["album", "book", "movie"].each do |cat|
          works[cat].length.must_be :>, 0
        end

        get root_path

        must_respond_with :success
      end

      it "succeeds with one media type absent" do
        Work.where(category: :movie).destroy_all
        Work.where(category: :movie).must_be_empty

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

    describe "guest user" do
      it "succeeds with all media types" do
        works = Work.to_category_hash
        ["album", "book", "movie"].each do |cat|
          works[cat].length.must_be :>, 0
        end

        get root_path

        must_respond_with :success
      end

      it "succeeds with one media type absent" do
        Work.where(category: :movie).destroy_all
        Work.where(category: :movie).must_be_empty

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
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do
    describe "logged in user" do
      before do
        login(User.first)
      end

      it "succeeds when there are works" do
        Work.count.must_be :>, 0

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

    describe "guest user" do
      it "cannot access index" do
        get works_path

        must_respond_with :redirect
        must_redirect_to root_path
        flash[:result_text].must_equal "You must log in to do that"
      end
    end
  end

  describe "new" do
    it "succeeds for logged in user" do
      login(User.first)

      get new_work_path

      must_respond_with :success
    end

    it "cannot access new route as guest user" do
      get new_work_path

      must_respond_with :redirect
      must_redirect_to root_path
      flash[:result_text].must_equal "You must log in to do that"
    end
  end

  describe "create" do
    describe "logged in user" do
      before do
        login(User.first)
      end

      it "creates a work with valid data for a real category" do
        work_data = {
          title: 'great stuff',
          category: CATEGORIES.sample.singularize
        }
        Work.new(work_data).must_be :valid?
        old_work_count = Work.count

        post works_path, params: { work: work_data }

        must_respond_with :redirect
        must_redirect_to work_path(Work.last.id)
        Work.count.must_equal old_work_count + 1
        Work.last.title.must_equal work_data[:title]
      end

      it "renders bad_request and does not update the DB for bogus data" do
        work_data = {
          title: '',
          category: CATEGORIES.sample.singularize
        }
        Work.new(work_data).wont_be :valid?
        old_work_count = Work.count

        post works_path, params: { work: work_data }

        must_respond_with :bad_request
        Work.count.must_equal old_work_count
      end

      it "renders 400 bad_request for bogus categories" do
        work_data = {
          title: 'great stuff',
          category: INVALID_CATEGORIES.sample
        }
        Work.new(work_data).wont_be :valid?
        old_work_count = Work.count

        post works_path, params: { work: work_data }

        must_respond_with :bad_request
        Work.count.must_equal old_work_count
      end
    end

    describe "guest user" do
      it "cannot access create route" do
        work_data = {
          title: 'great stuff',
          category: CATEGORIES.sample.singularize
        }

        post works_path, params: { work: work_data }

        must_respond_with :redirect
        must_redirect_to root_path
        flash[:result_text].must_equal "You must log in to do that"
      end
    end
  end

  describe "show" do
    describe "logged in user" do
      before do
        login(User.first)
      end

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

    describe "guest user" do
      it "cannot access show route" do
        work_id = Work.first.id

        get work_path(work_id)

        must_respond_with :redirect
        must_redirect_to root_path
        flash[:result_text].must_equal "You must log in to do that"
      end
    end
  end

  describe "edit" do
    describe "logged in user" do
      before do
        login(User.first)
      end

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

    describe "guest user" do
      it "cannot access edit route" do
        work_id = Work.first.id

        get edit_work_path(work_id)

        must_respond_with :redirect
        must_redirect_to root_path
        flash[:result_text].must_equal "You must log in to do that"
      end
    end
  end

  describe "update" do
    describe "logged in user" do
      before do
        login(User.first)
      end

      it "succeeds for valid data and an extant work ID" do
        work_id = Work.first.id
        work_data = {
          title: 'new title'
        }

        patch work_path(work_id), params: { work: work_data }

        must_respond_with :redirect
        must_redirect_to work_path(work_id)
        Work.first.title.must_equal 'new title'
      end

      it "renders not_found and does not update database for bogus data" do
        work_id = Work.first.id
        work_data = {
          title: nil
        }

        patch work_path(work_id), params: { work: work_data }
        must_respond_with :not_found
        Work.first.title.wont_be_nil
      end

      it "renders 404 not_found and does not update DB for a bogus work ID" do
        work_id = Work.last.id + 1
        old_work_count = Work.count
        work_data = {
          title: 'new title'
        }

        patch work_path(work_id), params: { work: work_data }

        must_respond_with :not_found
        Work.count.must_equal old_work_count
      end
    end

    describe "guest user" do
      it "cannot access update route" do
        work_id = Work.first.id
        work_data = {
          title: 'new title'
        }

        patch work_path(work_id), params: { work: work_data }

        must_respond_with :redirect
        must_redirect_to root_path
        flash[:result_text].must_equal "You must log in to do that"
      end
    end
  end

  describe "destroy" do
    describe "logged in user" do
      before do
        login(User.first)
      end

      it "succeeds for an extant work ID" do
        work_id = Work.first.id
        old_work_count = Work.count

        delete work_path(work_id)

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

    describe "guest user" do
      it "cannot access delete route" do
        work_id = Work.first.id

        delete work_path(work_id)

        must_respond_with :redirect
        must_redirect_to root_path
        flash[:result_text].must_equal "You must log in to do that"
      end
    end
  end

  describe "upvote" do
    it "redirects to the root page if no user is logged in" do
      work_id = Work.first.id

      post upvote_path(work_id)

      must_respond_with :redirect
      must_redirect_to root_path
      flash[:result_text].must_equal "You must log in to do that"
    end

    it "redirects to the root page after the user has logged out" do
      login(User.first)
      delete logout_path(User.first.id)

      post upvote_path(works(:poodr).id)

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      login(User.first)
      work = works(:poodr)
      votes_before = work.votes.count

      post upvote_path(work.id)

      flash[:result_text].must_equal "Successfully upvoted!"
      must_respond_with :redirect
      must_redirect_to work_path(work.id)
      Work.find_by(id: works(:poodr).id).votes.count.must_equal votes_before + 1
    end

    it "redirects to the work page if the user has already voted for that work" do
      login(users(:dan))
      work = works(:album)
      votes_before = work.votes.count

      post upvote_path(work.id)

      flash[:result_text].must_equal "Could not upvote"
      must_respond_with :redirect
      must_redirect_to work_path(work.id)
      Work.find_by(id: works(:album).id).votes.count.must_equal votes_before
    end
  end
end
