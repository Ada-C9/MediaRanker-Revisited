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
    it "succeeds when there are works" do

      @book = works(:poodr)
      @movie = works(:movie)

      get works_path
      must_respond_with :success

    end

    it "succeeds when there are no works" do

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
    it "succeeds for an extant work ID" do

      test_work = Work.first
      test_work.wont_be_nil

      get work_path(test_work.id)

      must_respond_with :success

    end

    it "renders 404 not_found for a bogus work ID" do

      bogus_id = 4
      Work.find_by(id: bogus_id).must_be_nil

      get work_path(bogus_id)

      must_respond_with :not_found

    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do

      test_work = Work.first
      test_work.wont_be_nil

      get edit_work_path(test_work.id)

      must_respond_with :success

    end

    it "renders 404 not_found for a bogus work ID" do

      bogus_id = 1
      Work.find_by(id: bogus_id).must_be_nil

      get edit_work_path(bogus_id)

      must_respond_with :not_found

    end
  end

  describe "update" do

    it "succeeds for valid data and an extant work ID" do

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

    it "succeeds for an extant work ID" do

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

      bogus_id = 3
      Work.find_by(id: bogus_id).must_be_nil

      proc {
        delete work_path(bogus_id)
      }.must_change 'Work.count', 0

      must_respond_with :not_found

    end
  end

  describe "upvote" do

    it "redirects to the work page if no user is logged in" do

      work = Work.first

      post upvote_path(work.id)

      must_redirect_to work_path(work.id)

    end

    it "redirects to the work page after the user has logged out" do

      work_p = Work.find_by(title: "Practical Object Oriented Design in Ruby")
      post login_path, params: {username: "kari"}
      post logout_path
      session[:user_id].must_be_nil

      post upvote_path(work_p.id)
      must_redirect_to work_path(work_p.id)


    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do

      user_k = User.find_by(username: "kari")
      work_p = Work.find_by(title: "Practical Object Oriented Design in Ruby")

      post login_path, params: {username: "kari"}
      # setup { login params: {username:  "kari"}}
      session[:user_id].must_equal user_k.id

      post upvote_path(work_p.id)

      flash[:result_text].must_equal "Successfully upvoted!"

    end

    it "redirects to the work page if the user has already voted for that work" do

      user_k = User.find_by(username: "kari")
      work_a = Work.find_by(title: "Old Title")

      post login_path, params: {username: "kari"}
      # setup { login params: {username:  "kari"}}
      session[:user_id].must_equal user_k.id

      post upvote_path(work_a.id)

      flash[:result_text].must_equal "Could not upvote"
      must_redirect_to work_path(work_a.id)


    end
  end
end
