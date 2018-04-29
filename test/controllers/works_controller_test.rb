require 'test_helper'

describe WorksController do
  let(:poodruby) { works(:poodr) }
  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category
      get root_path

      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      poodruby.destroy

      get root_path

      must_respond_with :success
    end

    it "succeeds with no media" do
      Work.all do |work|
        work.destroy
      end

      get root_path

      must_respond_with :success
    end

    it "succeeds with an user logged in" do
      # Precondition: there is at least one media of each category
      perform_login(users(:dan))

      get root_path

      must_respond_with :success
    end
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do
    it "succeeds when there are works" do
      perform_login(users(:dan))

      get works_path

      must_respond_with :success
    end

    it "succeeds when there are no works" do
      Work.all do |work|
        work.destroy
      end
      perform_login(users(:dan))

      get works_path

      must_respond_with :success
    end

    it "redirects to root_path if no user is logged in" do
      get works_path

      must_respond_with :redirect
      must_redirect_to root_path
    end
  end

  describe "new" do
    it "succeeds" do
      perform_login(users(:dan))

      get new_work_path

      must_respond_with :success
    end

    it "redirects to root_path if no user is logged in" do
      get new_work_path

      must_respond_with :redirect
      must_redirect_to root_path
    end
  end

  describe "create" do
    it "creates a work with valid data for a real category" do
      new_work = {work: {title: 'Throne of Glass', category: 'book'}}
      perform_login(users(:dan))

      proc { post works_path, params: new_work }.must_change 'Work.count', 1

      new_work_id = Work.find_by(title: 'Throne of Glass').id

      must_respond_with :redirect
      must_redirect_to work_path(new_work_id)
    end

    it "renders bad_request and does not update the DB for bogus data" do
      bad_work = {work: {title: nil, category: 'book'}}
      perform_login(users(:dan))

      proc { post works_path, params: bad_work }.wont_change 'Work.count'

      must_respond_with 400

      # can you test that a controller renders instead of redirects the view?
    end

    it "renders 400 bad_request for bogus categories" do
      counter = 1
      INVALID_CATEGORIES.each do |category|
        invalid_work = {work: {title: 'Bad Title #{counter}', category: category}}
        perform_login(users(:dan))

        proc { post works_path, params: invalid_work }.wont_change 'Work.count'

        Work.find_by(title: 'Bad Title #{counter}').must_be_nil
        must_respond_with 400
      end
    end

    it "redirects to root_path if no user is logged in" do
      new_work = {work: {title: 'Throne of Glass', category: 'book'}}

      proc { post works_path, params: new_work }.wont_change 'Work.count'

      must_respond_with :redirect
      must_redirect_to root_path
    end
  end

  describe "show" do
    it "succeeds for an extant work ID" do
      perform_login(users(:dan))

      get work_path(poodruby.id)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      destroyed_id = poodruby.id
      poodruby.destroy
      perform_login(users(:dan))

      get work_path(destroyed_id)

      must_respond_with 404
    end
    it "redirects to root_path if no user is logged in" do
      get work_path(poodruby.id)

      must_respond_with :redirect
      must_redirect_to root_path
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do
      perform_login(users(:dan))

      get edit_work_path(poodruby.id)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      perform_login(users(:dan))

      destroyed_id = poodruby.id
      poodruby.destroy

      get edit_work_path(destroyed_id)

      must_respond_with 404
    end
    it "redirects to root_path if no user is logged in" do
      get edit_work_path(poodruby.id)

      must_respond_with :redirect
      must_redirect_to root_path
    end
  end

  describe "update" do
    it "succeeds for valid data and an extant work ID" do
      updates = {work: {title: "Another Bicycle", category: "book"}}
      perform_login(users(:dan))

      put work_path(poodruby), params: updates
      updated_poodr = Work.find_by(id: poodruby.id)

      updated_poodr.title.must_equal "Another Bicycle"
      must_respond_with :redirect
      must_redirect_to work_path(poodruby.id)
    end

    it "renders not_found for bogus data" do
      updates = {work: {title: nil, category: "book"}}
      perform_login(users(:dan))

      put work_path(poodruby), params: updates
      updated_poodr = Work.find_by(id: poodruby.id)

      must_respond_with 404
    end

    it "renders 404 not_found for a bogus work ID" do
      work = works(:album)
      id = work.id
      work.destroy
      perform_login(users(:dan))

      put work_path(id), params: {work: {title: "blah", category: "album"}}

      must_respond_with 404
    end
    it "redirects to root_path if no user is logged in" do
      work = works(:album)
      id = work.id

      put work_path(id), params: {work: {title: "blah", category: "album"}}

      must_respond_with :redirect
      must_redirect_to root_path
    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do
      perform_login(users(:dan))

      proc { delete work_path(poodruby.id) }.must_change "Work.count", -1

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      perform_login(users(:dan))

      id = poodruby.id
      poodruby.destroy

      proc { delete work_path(poodruby.id) }.wont_change "Work.count"

      must_respond_with 404
    end
    it "redirects to root_path and wont delete record if no user is logged in" do
      proc { delete work_path(poodruby.id) }.wont_change "Work.count"

      must_respond_with :redirect
      must_redirect_to root_path
    end
  end

  describe "upvote" do
    it "succeeds for a logged-in user and a fresh user-vote pair" do
      perform_login(users(:dan))

      proc { post upvote_path(poodruby.id) }.must_change "Vote.count", 1

      must_respond_with :redirect
      must_redirect_to work_path(poodruby.id)
    end

    it "redirects to the work page if the user has already voted for that work" do
      perform_login(users(:dan))

      proc { post upvote_path(works(:album).id) }.wont_change "Vote.count"

      must_respond_with :redirect
      must_redirect_to work_path(works(:album).id)
    end

    it "redirects to the root page if no user is logged in" do
      proc { post upvote_path(poodruby.id) }.wont_change "Vote.count"

      must_respond_with :redirect
      must_redirect_to root_path
    end
  end
end
