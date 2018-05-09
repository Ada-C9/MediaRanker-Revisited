require 'test_helper'

describe WorksController do
  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category

      get root_path
      must_respond_with :success
    end


    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      book = works(:poodr)
      book.delete

      Work.all.count.must_equal 3
      get root_path
      must_respond_with :success
    end

    it "succeeds with no media" do
      works(:poodr).destroy
      works(:album).destroy
      works(:another_album).destroy
      works(:movie).destroy

      Work.all.count.must_equal 0
      get root_path
      must_respond_with :success

    end
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "logged in users" do
    before do
      user = users(:grace)
      login(user)
    end

    describe "index" do
      it "succeeds when there are works" do

        get works_path
        must_respond_with :success

      end


      it "succeeds when there are no works" do
        works(:poodr).destroy
        works(:album).destroy
        works(:another_album).destroy
        works(:movie).destroy

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

        proc {
          post works_path, params: { work: { title: "New Things", category: "album", creator: "Gucci Mane", id: 2000} }
        }.must_change 'Work.count', 1

        work = Work.find_by(title: "New Things")

        must_respond_with :redirect
        must_redirect_to work_path(Work.last)
      end

      it "renders bad_request and does not update the DB for bogus data" do
        post works_path, params: { work: { title: "", category: "album", creator: "Gucci Mane" } }

        must_respond_with :bad_request
        Work.all.count.must_equal 4
      end

      it "renders 400 bad_request for bogus categories" do
        post works_path, params: { work: { title: "ok", category: "vhs", creator: "Gucci Mane" } }

        must_respond_with :bad_request
        Work.all.count.must_equal 4
      end

    end

    describe "show" do
      it "succeeds for an extant work ID" do
        work = works(:poodr)

        get work_path(work.id)
        must_respond_with :success

      end

      it "renders 404 not_found for a bogus work ID" do
        get work_path("abc")
        must_respond_with :not_found
      end
    end



    describe "edit" do
      it "succeeds for an extant work ID" do
        work = works(:poodr)

        get edit_work_path(work.id)
        must_respond_with :success
      end

      it "renders 404 not_found for a bogus work ID" do
        get edit_work_path("abc")
        must_respond_with :not_found
      end
    end

    describe "update" do
      it "succeeds for valid data and an extant work ID" do
       updated_author = "JWoww"
       work = works(:poodr)

        put work_path(work.id), params: { work: { creator: updated_author}  }

        updated_work = Work.find(work.id)
        updated_work.creator.must_equal "JWoww"
      end

      it "renders not_found for bogus data" do

        put work_path(works(:poodr).id), params: { work: { title: nil}  }
        must_respond_with :not_found
      end


      it "renders 404 not_found for a bogus work ID" do
        put work_path('abc'), params: { work: { title: nil}  }
        must_respond_with :not_found
      end
    end


    describe "destroy" do
      it "succeeds for an extant work ID" do
        work = works(:another_album)
        proc {
          delete work_path(work.id)}.must_change 'Work.count', -1
      end

      it "renders 404 not_found and does not update the DB for a bogus work ID" do

        proc {
          delete work_path('abc')}.must_change 'Work.count', 0
      end

    end

    describe "upvote" do
      # changed redirect location because of authentication requirements
      it "redirects to the root page if no user is logged in" do
        work = works(:poodr)
        delete logout_path

        post upvote_path(work.id)

        must_redirect_to root_path
      end


      it "redirects to the work page after the user has logged out" do
        work = works(:poodr)

        post upvote_path(work.id)
        delete logout_path

        must_redirect_to root_path
      end

      it "succeeds for a logged-in user and a fresh user-vote pair" do
        work = works(:poodr)
        work.votes.count.must_equal 0

        post upvote_path(work.id)

        work.votes.count.must_equal 1
      end

      it "redirects to the work page if the user has already voted for that work" do
        work = works(:poodr)
        user = users(:grace)

        work.votes.count.must_equal 0
        post upvote_path(work.id), params: { vote: { user_id: user.id, work_id: work.id}  }
        post upvote_path(work.id), params: { vote: { user_id: user.id, work_id: work.id}  }
        work.votes.count.must_equal 1

        must_redirect_to work_path(work.id)
      end
    end
  end

  describe "guest users" do

    describe "index" do
      it "cannot be accessed" do

        get works_path
        must_respond_with :redirect
        flash[:result_text].must_equal "You must be logged in to see that page!"
      end
    end

    describe "new" do
      it "cannot be accessed" do

        get new_work_path
        must_respond_with :redirect
        flash[:result_text].must_equal "You must be logged in to see that page!"
      end
    end

    describe "create" do
      it "cannot be accessed" do

        post works_path
        must_respond_with :redirect
        flash[:result_text].must_equal "You must be logged in to see that page!"
      end
    end

    describe "edit" do
      it "cannot be accessed" do
        work = works(:poodr)

        get edit_work_path(work.id)
        must_respond_with :redirect
        flash[:result_text].must_equal "You must be logged in to see that page!"
      end
    end

    describe "destroy" do
      it "cannot be accessed" do
        work = works(:poodr)

        delete work_path(work.id)
        must_respond_with :redirect
        flash[:result_text].must_equal "You must be logged in to see that page!"
      end
    end

    describe "upvote" do
      it "cannot be accessed" do
        work = works(:poodr)

        post upvote_path(work.id)
        must_respond_with :redirect
        flash[:result_text].must_equal "You must be logged in to see that page!"
      end
    end

    describe "update" do
      it "cannot be accessed" do
        work = works(:poodr)

        put work_path(work.id)
        must_respond_with :redirect
        flash[:result_text].must_equal "You must be logged in to see that page!"
      end
    end
  end

end
