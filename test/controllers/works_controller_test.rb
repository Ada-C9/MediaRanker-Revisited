require 'test_helper'

describe WorksController do

  describe "Logged in user" do
    before do
      @user = users(:dan)
    end

    describe "root" do
      it "succeeds with all media types" do
        login(@user)

        get root_path

        must_respond_with :success
      end

      it "succeeds with one media type absent" do
        Work.all.where(category: "album").each do |work|
          work.destroy
        end

        login(@user)

        get root_path

        Work.all.count.wont_equal 0
        Work.all.where(category: "album").count.must_equal 0
        must_respond_with :success
      end

      it "succeeds with no media" do
        Work.all.each do |work|
          work.destroy
        end

        login(@user)

        get root_path
        must_respond_with :success
      end
    end

    CATEGORIES = %w(albums books movies)
    INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

    describe "index" do
      it "succeeds when there are works" do
        login(@user)

        get works_path

        must_respond_with :success
      end

      it "succeeds when there are no works" do
        Work.all.each do |work|
          work.destroy
        end
        login(@user)

        get works_path

        Work.all.count.must_equal 0
        must_respond_with :success
      end
    end

    describe "new" do
      it "succeeds" do
        login(@user)

        get new_work_path

        must_respond_with :success
      end
    end

    describe "create" do
      it "creates a work with valid data for a real category" do
        login(@user)

        proc {
          post works_path, params: {
            work: {
              title: "New Work",
              category: "movie"
            }
          }
        }.must_change 'Work.count', 1

        work_id = Work.find_by(title: "New Work").id

        flash[:status].must_equal :success
        must_respond_with :redirect
        must_redirect_to work_path(work_id)
      end

      it "renders bad_request and does not update the DB for bogus data" do
        login(@user)

        proc {
          post works_path, params: {
            work: {
              category: ""
            }
          }
        }.must_change 'Work.count', 0

        flash.now[:status].must_equal :failure
        must_respond_with :bad_request
      end

      it "renders 400 bad_request for bogus categories" do
        login(@user)

        proc {
          post works_path, params: {
            work: {
              title: "New Work",
              category: "Fake_Category"
            }
          }
        }.must_change 'Work.count', 0

        flash.now[:status].must_equal :failure
        must_respond_with :bad_request
      end
    end

    describe "show" do
      it "succeeds for an extant work ID" do
        login(@user)

        get work_path(works(:album).id)

        must_respond_with :success
      end

      it "renders 404 not_found for a bogus work ID" do
        login(@user)

        get work_path("fake_work")

        must_respond_with :not_found
      end
    end

    describe "edit" do
      it "succeeds for an extant work ID" do
        login(@user)

        get edit_work_path(works(:album).id)

        must_respond_with :success
      end

      it "renders 404 not_found for a bogus work ID" do
        login(@user)

        get edit_work_path("Fake_work_id")

        must_respond_with :not_found
      end
    end

    describe "update" do
      it "succeeds for valid data and an extant work ID" do
        login(@user)

        put work_path(works(:album).id), params: {
          work: {
            title: "Old Title"
          }
        }
        flash[:status].must_equal :success
        must_respond_with :redirect
        must_redirect_to work_path(works(:album).id)
      end

      it "renders 404 not_found for bogus data" do
        login(@user)

        put work_path(works(:album).id), params: {
          work: {
            category: "Fake_data"
          }
        }

        flash.now[:status].must_equal :failure
        must_respond_with :not_found
      end

      it "renders 404 not_found for a bogus work ID" do
        login(@user)

        put work_path("Fake_work_id")

        must_respond_with :not_found
      end
    end

    describe "destroy" do
      it "succeeds for an extant work ID" do
        login(@user)

        proc {
          delete work_path(works(:album).id)
        }.must_change 'Work.count', -1

        must_respond_with :redirect
        must_redirect_to root_path
      end

      it "renders 404 not_found and does not update the DB for a bogus work ID" do
        login(@user)

        proc {
          delete work_path("Fake_work_id")
        }.must_change 'Work.count', 0

        must_respond_with 404
      end
    end

    describe "upvote" do
      it "succeeds for a logged-in user and a fresh user-vote pair" do
        login(@user)

        post upvote_path(works(:movie).id)

        flash[:status].must_equal :success
        must_respond_with :redirect
        must_redirect_to work_path(works(:movie).id)
      end

      it "redirects to the work page if the user has already voted for that work" do
        login(@user)

        post upvote_path(works(:album).id)

        flash[:status].must_equal :failure
        must_respond_with :redirect
        must_redirect_to work_path(works(:album).id)
      end
    end
  end

  describe "Guest users" do
    describe "root" do
      it "succeeds with all media types" do
        get root_path

        must_respond_with :success
      end

      it "succeeds with one media type absent" do
        Work.all.where(category: "album").each do |work|
          work.destroy
        end

        get root_path

        Work.all.count.wont_equal 0
        Work.all.where(category: "album").count.must_equal 0
        must_respond_with :success
      end

      it "succeeds with no media" do
        Work.all.each do |work|
          work.destroy
        end

        get root_path
        must_respond_with :success
      end
    end

    describe "index" do
      it "cannot get to works index path" do
        get works_path

        flash[:status].must_equal :failure
        must_respond_with :redirect
        must_redirect_to root_path
      end
    end

    describe "new" do
      it "cannot get to new work path" do
        get new_work_path

        flash[:status].must_equal :failure
        must_respond_with :redirect
        must_redirect_to root_path
      end
    end

    describe "create" do
      it "cannot get to create work path" do
        post works_path, params: {
          work: {
            title: "New Work",
            category: "album"
          }
        }

        flash[:status].must_equal :failure
        must_respond_with :redirect
        must_redirect_to root_path
      end
    end

    describe "show" do
      it "cannot get to show with work id" do
        get work_path(works(:album).id)

        flash[:status].must_equal :failure
        must_respond_with :redirect
        must_redirect_to root_path
      end

      it "cannot get to show page for a bogus work ID" do
        get work_path("Fake_work_id")

        flash[:status].must_equal :failure
        must_respond_with :redirect
        must_redirect_to root_path
      end
    end

    describe "edit" do
      it "cannot get to edit page for an extant work ID" do
        get edit_work_path(works(:album).id)

        flash[:status].must_equal :failure
        must_respond_with :redirect
        must_redirect_to root_path
      end

      it "cannot get to edit page for a bogus work ID" do
        get edit_work_path("foo")

        flash[:status].must_equal :failure
        must_respond_with :redirect
        must_redirect_to root_path
      end
    end

    describe "update" do
      it "cannot update valid data for an extant work ID" do
        put work_path(works(:album).id), params: {
          work: {
            title: "New Title"
          }
        }

        flash[:status].must_equal :failure
        must_respond_with :redirect
        must_redirect_to root_path
      end

      it "cannot get to update with bogus data" do
        put work_path(works(:album).id), params: {
          work: {
            category: "Fake!"
          }
        }

        flash[:status].must_equal :failure
        must_respond_with :redirect
        must_redirect_to root_path
      end

      it "cannot access update for a bogus work ID" do
        put work_path("Fake_data")

        flash[:status].must_equal :failure
        must_respond_with :redirect
        must_redirect_to root_path
      end
    end

    describe "destroy" do
      it "cannot access destroy for an extant work ID" do
        delete work_path(works(:album).id)

        flash[:status].must_equal :failure
        must_respond_with :redirect
        must_redirect_to root_path
      end

      it "cannot access destroy for a bogus work ID" do
        delete work_path("Fake_data")

        flash[:status].must_equal :failure
        must_respond_with :redirect
        must_redirect_to root_path
      end
    end

    describe "upvote" do
      it "redirects to the work page if no user is logged in" do
        post upvote_path(works(:album).id)

        flash[:status].must_equal :failure
        must_respond_with :redirect
        must_redirect_to root_path
      end

      it "redirects to the work page after the user has logged out" do
        login(users(:dan))
        logout(users(:dan))

        post upvote_path(works(:album).id)

        flash[:status].must_equal :failure
        must_respond_with :redirect
        must_redirect_to root_path
      end
    end

  end
end
