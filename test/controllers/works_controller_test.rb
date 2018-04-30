require 'test_helper'

describe WorksController do
  describe "root" do
    it "succeeds with all media types" do

      works << Work.find_by_category("album")
      works << Work.find_by_category("book")
      works << Work.find_by_category("movie")
      works.include?(nil).must_equal false

      get root_path
      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      Work.find_by_category("album").nil?.must_equal false
      Work.find_by_category("book").nil?.must_equal false
      Work.destroy_all(category: "movie")
      Work.find_by_category("movie").must_equal nil

      get root_path
      must_respond_with :success
    end

    it "succeeds with no media" do
      Work.destroy_all
      Work.all.count.must_equal 0

      get root_path
      must_respond_with :success
    end
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do
    it "succeeds when there are works" do
      works << Work.find_by_category("album")
      works << Work.find_by_category("book")
      works << Work.find_by_category("movie")
      works.include?(nil).must_equal false

      get works_path
      must_respond_with :success
    end

    it "succeeds when there are no works" do
      Work.destroy_all
      Work.all.count.must_equal 0

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
      proc  {
        post works_path, params: { work:
          {
            title:  "Beychella" ,
            creator: "Who Creates" ,
            description: "This is an album" ,
            publication_year: 2018-04-16 ,
            category: "album"
          }
        }
      }.must_change 'Work.count', 1
    end

    it "renders bad_request and does not update the DB for bogus data" do
      proc  {
        post works_path, params: { work:
          {
            title:  nil ,
            creator: "Who Creates" ,
            description: "This is an album" ,
            publication_year: 2018-04-16 ,
            category: "album"
          }
        }
      }.must_change 'Work.count', 0
      must_respond_with :bad_request
    end

    it "renders 400 bad_request for bogus categories" do
      proc  {
        post works_path, params: { work:
          {
            title:  "valid title" ,
            creator: "valid autor" ,
            description: "This is an album" ,
            publication_year: 2018-04-16 ,
            category: "nope"
          }
        }
      }.must_change 'Work.count', 0
      must_respond_with :bad_request
    end

  end

  describe "show" do
    it "succeeds for an extant work ID" do
      get work_path(works(:album))
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      get work_path(-1)
      must_respond_with :missing
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do
      get edit_work_path((works(:album)).id)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      get edit_work_path(-1)
      must_respond_with :missing
    end
  end

  describe "update" do
    it "succeeds for valid data and an extant work ID" do
      work = works(:album)

      proc  {
        patch work_path(work.id) , params: { work:
          {
          title: "Beychella2",
          creator: "Who Creates" ,
          description: "This is an album" ,
          publication_year: 2018-04-16 ,
          category: "album"
          }
        }
      }.must_change 'Work.count', 0

      Work.find(work.id).title.must_equal "Beychella2"
      must_respond_with :redirect
      must_redirect_to work_path(work.id)
    end

    # changed this to missing because of controller action method status is a 404 not error
    it "renders not_found for bogus data" do
      work = works(:album)

      proc  {
        patch work_path(work.id) , params: { work:
          {
          title: nil,
          creator: "Who Creates" ,
          description: "This is an album" ,
          publication_year: 2018-04-16 ,
          category: "album"
          }
        }
      }.must_change 'Work.count', 0

      Work.find(work.id).title.must_equal "Old Title"

      must_respond_with :missing
    end

    it "renders 404 not_found for a bogus work ID" do
      proc  {
        patch work_path(-1) , params: { work:
          {
          title: "Beychella_Forever",
          creator: "Who Creates" ,
          description: "This is an album" ,
          publication_year: 2018-04-16 ,
          category: "album"
          }
        }
      }.must_change 'Work.count', 0

      must_respond_with :missing
    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do
      work = works(:album)
      proc  {
        delete work_path(work.id)
      }.must_change 'Work.count', -1

      Work.find_by(id: work.id).must_equal nil
      must_respond_with :redirect
      must_redirect_to :root
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      proc  {
        delete work_path(-1)
      }.must_change 'Work.count', 0

      must_respond_with :missing
    end
  end

  describe "upvote" do

    it "redirects to the work page if no user is logged in" do
      # should I do a logout and check session to ensure no user is logged in?
      work = works(:album)
      # post logout_path
      # session[:user_id].nil?.must_equal true
      post upvote_path(work.id)
      must_respond_with :redirect
      must_redirect_to work_path(work.id)
    end

    it "redirects to the work page after the user has logged out" do
      post login_path, params: { username: users(:dan) }

      work = works(:album)
      post logout_path
      session[:user_id].nil?.must_equal true

      post upvote_path(work.id)
      must_respond_with :redirect
      must_redirect_to work_path(work.id)
    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      post login_path, params: { username: users(:kari) }

      work = works(:another_album)

      proc {
        post upvote_path(work.id)
      }.must_change 'Vote.count', 1
      must_respond_with :redirect
      must_redirect_to work_path(work.id)
    end

    it "redirects to the work page if the user has already voted for that work" do
      user = users(:dan)
      work = works(:album)

      post login_path, params: { username: user.username }

      Vote.where(:user_id => (user.id)).where(:work_id => (work.id)).nil?.must_equal false

      proc {
        post upvote_path(work.id)
      }.must_change 'Vote.count', 0
      must_respond_with :redirect
      must_redirect_to work_path(work.id)
    end
  end
end
