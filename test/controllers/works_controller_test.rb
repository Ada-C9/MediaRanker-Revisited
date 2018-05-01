require 'test_helper'
require 'pry'

describe WorksController do
  let(:album) { works(:album) }
  let(:another_album) { works(:another_album) }
  let(:book) { works(:poodr) }
  let(:movie) { works(:movie) }


  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category
      puts "Work.count"
      get root_path
      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      proc {
        book.destroy
      }.must_change 'Work.count', -1
      get root_path
      must_respond_with :success
    end

    it "succeeds with no media" do
      Work.destroy_all
      assert Work.all.empty?
      get root_path
      must_respond_with :success
    end

    it "succeeds with guest user" do
      get root_path
      must_respond_with :success
    end

    it "succeeds with logged in user" do
      perform_login(users(:dan))
      get root_path
      must_respond_with :success
    end
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do
    it "succeeds for signed in user when there are works" do
      perform_login(users(:dan))
      get works_path
      must_respond_with :success
    end

    it "renders 404 for guest users" do
      get works_path
      must_respond_with :missing
    end

    it "succeeds for guest users when there are no works" do
      perform_login(users(:dan))
      Work.destroy_all
      assert Work.all.empty?
      get root_path
      must_respond_with :success
    end
  end

  describe "new" do
    it "succeeds for signed in users" do
      perform_login(users(:dan))
      get new_work_path
      must_respond_with :success
    end

    it "renders 404 for guest users" do
      get new_work_path
      must_respond_with :missing
    end
  end

  describe "create" do
    it "creates a work with valid data for a real category only for signed in users" do
      perform_login(users(:dan))

      titles = ["one", "two", "three"]
      CATEGORIES.zip(titles).each do |category, title|
        proc {
          post works_path, params: {
            work: {
              title: title, category: category
            }
          }
        }.must_change 'Work.count', 1
        must_respond_with :redirect
        new_work = Work.find_by(title: title)
        must_redirect_to work_path(new_work)
      end
    end

    it "renders 404 for guest user" do

      titles = ["one", "two", "three"]
      CATEGORIES.zip(titles).each do |category, title|
        proc {
          post works_path, params: {
            work: {
              title: title, category: category
            }
          }
        }.must_change 'Work.count', 0
        must_respond_with :missing

      end
    end

    it "renders 400 bad_request for bogus categories for signed in users" do
      perform_login(users(:dan))

      titles = ["one", "two", "three", "four", "five"]
      INVALID_CATEGORIES.zip(titles).each do |category, title|
        proc {
          post works_path, params: {
            work: {
              title: title, category: category
            }
          }
        }.must_change 'Work.count', 0

        must_respond_with :bad_request

      end
    end

  end

  describe "show" do
    it "succeeds for an extant work ID for signed in users" do
      perform_login(users(:dan))


      get work_path(book)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID for logged in user" do
      perform_login(users(:dan))

      get work_path(123123123)
      must_respond_with :missing
    end

    it "renders 404 not_found for guest user" do

      get work_path(book)
      must_respond_with :missing

    end
  end

  describe "edit" do
    it "succeeds for an extant work ID for signed in user" do
      perform_login(users(:dan))
      get edit_work_path(book)
      must_respond_with :success
    end

    it "renders 404 for an extant work ID for guest user" do
      get edit_work_path(book)
      must_respond_with :missing
    end

    it "renders 404 not_found for a bogus work ID and signed in user" do
      perform_login(users(:dan))
      get edit_work_path(678678687678)
      must_respond_with :missing
    end
  end

  describe "update" do
    it "succeeds for valid data and an extant work ID for logged in users" do
      perform_login(users(:dan))
      updated_title = "Updated album name"
      patch work_path album.id, params: {
        work: {
          title: updated_title
        }
      }

      updated_work = Work.find(album.id)
      updated_work.title.must_equal updated_title
      must_respond_with :redirect
      must_redirect_to work_path(album.id)
    end

    it "renders 404 for valid data and an extant work ID guest users" do
      updated_title = "Updated album name"
      patch work_path album.id, params: {
        work: {
          title: updated_title
        }
      }

      must_respond_with :missing
    end

    it "renders not_found for bogus data for signed in users" do
      perform_login(users(:dan))
      updated_category = "bogus category"
      patch work_path(album.id), params: {
        work: {
          category: updated_category
        }
      }

      must_respond_with :missing

    end

    it "renders 404 not_found for a bogus work ID for signed in users" do
      perform_login(users(:dan))
      updated_title = "Updated album name"
      patch work_path("bogus book"), params: {
        work: {
          title: updated_title
        }
      }

      must_respond_with :missing
    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID for signed in user" do
      perform_login(users(:dan))
      proc {
        delete work_path(album.id)
      }.must_change 'Work.count', -1

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID for signed in user" do
      perform_login(users(:dan))
      proc {
        delete work_path("boguswork")
      }.must_change 'Work.count', 0

      must_respond_with :missing
    end

    it "renders 404 for an extant work ID for guest users" do
      proc {
        delete work_path(album.id)
      }.must_change 'Work.count', 0

      must_respond_with :missing
    end
  end

  describe "upvote" do

    it "redirects to the work page if no user is logged in" do
      proc {
        post upvote_path(album)
      }.must_change 'Vote.count', 0
      must_respond_with :redirect
      must_redirect_to work_path(album.id)
    end

    it "redirects to the work page after the user has logged out" do
      perform_login(users(:dan))
      perform_logout(users(:dan))
      proc {
        post upvote_path(album)
      }.must_change 'Vote.count', 0
      must_respond_with :redirect
      must_redirect_to work_path(album.id)

    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      perform_login(users(:dan))
      proc {
        post upvote_path(book)
      }.must_change 'Vote.count', 1
      must_respond_with :redirect

      proc {
        post upvote_path(book)
      }.must_change 'Vote.count', 0
      must_respond_with :redirect

    end

    it "redirects to the work page if the user has already voted for that work" do
      perform_login(users(:dan))
      proc {
        post upvote_path(album)
      }.must_change 'Vote.count', 0
      must_respond_with :redirect
    end
  end
end
