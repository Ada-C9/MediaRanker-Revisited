require 'test_helper'
require 'pry'

describe WorksController do

    CATEGORIES_OG = %w(album book movie)

    CATEGORIES_VG = ["album", "book", "movie"]
    INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

    BAD_TITLES = ["", "   ", "Old Title", ]


    describe "root" do

      before do

        @w_album = works(:album)
        @w_another_album = works(:another_album)
        @w_poodr = works(:poodr)
        @w_movie = works(:movie)

      end

      it "succeeds with all media types" do

        CATEGORIES_VG.each do |category|
          Work.find_by(category: category).wont_be_nil
        end

        get root_path
        must_respond_with :success

      end

      it "succeeds with one media type absent" do
        # Precondition: there is at least one media in two of the categories

        @w_movie.destroy
        category_total = 0

        CATEGORIES_VG.each do |category|
          if Work.find_by(category: category)
            category_total += 1
          end
        end

        category_total.must_equal 2
        get root_path
        must_respond_with :success

      end

      it "succeeds with no media" do

        @w_album.destroy
        @w_another_album.destroy
        @w_poodr.destroy
        @w_movie.destroy

        category_total = 0

        CATEGORIES_VG.each do |category|
          if Work.all.find_by(category: category)
            category_total += 1
          end
        end

        category_total.must_equal 0


        get root_path
        must_respond_with :success

      end

    end


    describe "index" do

      before do

        @w_album = works(:album)
        @w_another_album = works(:another_album)
        @w_poodr = works(:poodr)
        @w_movie = works(:movie)

      end

      #GUEST USER TEST:

      it "fails and redirects to the login path for a guest user" do

        get works_path
        must_respond_with :redirect
        must_redirect_to github_login_path

      end

      # LOGGED-IN USER TESTS:

      it "succeeds when there are works" do

        login(users(:kari))

        Work.all.count.must_be :>, 0

        get works_path
        must_respond_with :success

      end

      it "succeeds when there are no works" do

        login(users(:kari))

        @w_album.destroy
        @w_another_album.destroy
        @w_poodr.destroy
        @w_movie.destroy

        Work.all.count.must_equal 0

        get works_path
        must_respond_with :success

      end
    end

    describe "new" do

      #GUEST USER TEST:

      it "fails and redirects to the login path for a guest user" do

        get new_work_path
        must_respond_with :redirect
        must_redirect_to github_login_path

      end

      #LOGGED-IN USER TEST:

      it "succeeds" do

        login(users(:kari))

        get new_work_path
        must_respond_with :success
      end
    end

    describe "create" do

      #GUEST USER TEST:

      it "fails and redirects to the login path for a guest user" do

        post works_path
        must_respond_with :redirect
        must_redirect_to github_login_path

      end

      #LOGGED-IN USER TEST:

      it "creates a work with valid data for a real category" do

        login(users(:kari))

        proc {
          post works_path, params: {
            work: {
              title: "Hebdomeros",
              category: "books"
              }
            }
          }.must_change 'Work.count', 1

        test_work = Work.find_by(title: "Hebdomeros")

        must_respond_with :redirect
        must_redirect_to work_path(test_work.id)

      end

      it "renders bad_request and does not update the DB for bogus data" do

        login(users(:kari))

        BAD_TITLES.each do |bad_t|

          proc {
            post works_path, params: {
              work: {
                title: bad_t,
                category: "album"
                }
              }
            }.must_change 'Work.count', 0

          must_respond_with :bad_request

        end
      end

      it "renders 400 bad_request for bogus categories" do

        login(users(:kari))

        INVALID_CATEGORIES.each do |bog_cat|

          proc {
            post works_path, params: {
              work: {
                title: "Nella",
                category: bog_cat
                }
              }
            }.must_change 'Work.count', 0

          must_respond_with :bad_request
        end
      end

    end

    describe "show" do

      #GUEST USER TEST:

      it "fails and redirects to the login path for a guest user" do

        test_work = Work.first
        test_work.wont_be_nil

        get work_path(test_work.id)

        must_respond_with :redirect
        must_redirect_to github_login_path

      end

      #LOGGED-IN USER TESTS:

      it "succeeds for an extant work ID" do

        login(users(:kari))

        test_work = Work.first
        test_work.wont_be_nil

        get work_path(test_work.id)

        must_respond_with :success

      end

      it "renders 404 not_found for a bogus work ID" do

        login(users(:kari))

        bogus_id = 4
        Work.find_by(id: bogus_id).must_be_nil

        get work_path(bogus_id)

        must_respond_with :not_found

      end
    end

    describe "edit" do

      #GUEST USER TEST:

      it "fails and redirects to the login path for a guest user" do

        test_work = Work.first
        test_work.wont_be_nil

        get edit_work_path(test_work.id)

        must_respond_with :redirect
        must_redirect_to github_login_path

      end

      #LOGGED-IN USER TESTS:

      it "succeeds for an extant work ID" do

        login(users(:kari))

        test_work = Work.first
        test_work.wont_be_nil

        get edit_work_path(test_work.id)

        must_respond_with :success

      end

      it "renders 404 not_found for a bogus work ID" do

        login(users(:kari))

        bogus_id = 1
        Work.find_by(id: bogus_id).must_be_nil

        get edit_work_path(bogus_id)

        must_respond_with :not_found

      end
    end

    describe "update" do

      #GUEST USER TEST:

      it "fails and redirects to the login path for a guest user" do

        test_work = Work.last
        test_work.wont_be_nil

        patch work_path(test_work.id), params: {
          work: {
            title: "Ummagumma"
            }
          }

        must_respond_with :redirect
        must_redirect_to github_login_path

      end

      #LOGGED-IN USER TESTS:

      it "succeeds for valid data and an extant work ID" do

        login(users(:kari))

        test_work = Work.last

        patch work_path(test_work.id), params: {
          work: {
            title: "Ummagumma"
            }
          }

        must_redirect_to work_path(test_work.id)
        test_work.reload
        assert_equal "Ummagumma", test_work.title

      end

      it "renders 404 not_found for bogus data" do

        login(users(:kari))

        test_work = Work.find_by(title: "New Title")

        BAD_TITLES.each do |bad_t|

          put work_path(test_work.id), params: {
            work: {
              title: bad_t
              }
            }

          must_respond_with :not_found
          test_work.reload
          assert_equal "New Title", test_work.title
        end

      end

      it "renders 404 not_found for a bogus work ID" do

        login(users(:kari))

        test_work = Work.find_by(id: 2)
        test_work.must_be_nil

        patch work_path(2), params: {
            work: {
              title: "Ummagumma"
              }
            }

        must_respond_with :not_found

      end
    end

    describe "destroy" do

      #GUEST USER TEST:

      it "fails and redirects to the login path for a guest user" do

        test_id = Work.last.id
        Work.find_by(id: test_id).wont_be_nil

        delete work_path(test_id)

        must_respond_with :redirect
        must_redirect_to github_login_path

      end

      #LOGGED-IN USER TESTS:

      it "succeeds for an extant work ID" do

        login(users(:kari))

        test_id = Work.last.id
        Work.find_by(id: test_id).wont_be_nil

        proc {
          delete work_path(test_id)
        }.must_change 'Work.count', -1

        # must_respond_with :success

        Work.find_by(id: test_id).must_be_nil

        must_redirect_to root_path

      end

      it "renders 404 not_found and does not update the DB for a bogus work ID" do

        login(users(:kari))

        bogus_id = 3
        Work.find_by(id: bogus_id).must_be_nil

        proc {
          delete work_path(bogus_id)
        }.must_change 'Work.count', 0

        must_respond_with :not_found

      end
    end

    describe "upvote" do

      #GUEST USER TEST:

      it "fails and redirects to the login path for a guest user" do

        work = Work.first
        work.wont_be_nil

        post upvote_path(work.id)

        must_respond_with :redirect
        must_redirect_to github_login_path

      end

      #LOGGED-IN USER TESTS:

      it "redirects to the work page after the user has logged out" do

        login(users(:kari))

        session[:user_id].must_equal users(:kari).id
        work_p = Work.find_by(title: "Practical Object Oriented Design in Ruby")

        delete logout_path
        session[:user_id].must_be_nil

        post upvote_path(work_p.id)

        must_respond_with :redirect
        must_redirect_to github_login_path

      end

      it "succeeds for a logged-in user and a fresh user-vote pair" do

        login(users(:kari))

        user_k = User.find_by(username: "kari")
        work_p = Work.find_by(title: "Practical Object Oriented Design in Ruby")

        session[:user_id].must_equal user_k.id

        post upvote_path(work_p.id)

        flash[:result_text].must_equal "Successfully upvoted!"

      end

      it "redirects to the work page if the user has already voted for that work" do

        login(users(:kari))

        user_k = User.find_by(username: "kari")
        work_a = Work.find_by(title: "Old Title")

        session[:user_id].must_equal user_k.id

        post upvote_path(work_a.id)

        flash[:result_text].must_equal "Could not upvote"
        must_redirect_to work_path(work_a.id)


      end
    end
end
