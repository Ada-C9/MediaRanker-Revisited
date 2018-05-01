require 'test_helper'

describe WorksController do

  describe "Logged in users" do
    describe "show" do
      before do
        login(users(:kari))
      end

      # Just the standard show tests
      it "succeeds for a book that exists" do
        work_id = Work.first.id
        get work_path(work_id)
        must_respond_with :success
      end

      # it "returns 404 not_found for a book that D.N.E." do
      #   work_id = Work.last.id + 1
      #   get work_path(work_id)
      #   must_respond_with :not_found
      # end
    end
  end
  # # root -----------------------------------------------------------------------
  # describe "root" do
  #   it "succeeds with all media types" do
  #     Work.count.must_equal 4
  #     get root_path
  #     must_respond_with :success
  #   end
  #
  #   it "succeeds with one media type absent" do
  #     works(:movie).destroy
  #     Work.count.must_equal 3 # not needed but just to confirm that is worked
  #     get root_path
  #     must_respond_with :success
  #   end
  #
  #   it "succeeds with no media" do
  #     Work.all.each { |work| work.destroy }
  #     Work.count.must_equal 0 # not needed but just to confirm that is worked
  #     get root_path
  #     must_respond_with :success
  #   end
  # end
  #
  # CATEGORIES = %w[albums books movies]
  # INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]
  #
  # # index ----------------------------------------------------------------------
  # describe "index" do
  #   it "succeeds when there are works" do
  #     get works_path
  #     must_respond_with :success
  #   end
  #
  #   it "succeeds when there are no works" do
  #     Work.all.each { |work| work.destroy }
  #     Work.count.must_equal 0 # not needed but just to confirm that is worked
  #     get works_path
  #     must_respond_with :success
  #   end
  # end
  #
  # # new ------------------------------------------------------------------------
  # describe "new" do
  #   it "succeeds" do
  #     get new_work_path
  #     must_respond_with :success
  #   end
  # end
  #
  # # create ---------------------------------------------------------------------
  # describe "create" do
  #   it "creates a work with valid data for a real category" do
  #     proc {
  #       CATEGORIES.each do |work_category|
  #         post works_path, params: {
  #           work: { category: work_category, title: "foo" }
  #         }
  #         work = Work.where(title: "foo").last
  #
  #         must_redirect_to work_path(work)
  #         must_respond_with :redirect
  #       end
  #     }.must_change 'Work.count', 3
  #
  #   end
  #
  #   it "renders bad_request and does not update the DB for bogus data" do
  #     bogus_data = ["Practical Object Oriented Design in Ruby", nil]
  #     proc {
  #       bogus_data.each do |bogus|
  #         post works_path, params: { work: { title: bogus , category: "book" } }
  #         must_respond_with :bad_request
  #       end
  #     }.wont_change 'Work.count'
  #   end
  #
  #   it "renders 400 bad_request for bogus categories" do
  #     proc {
  #       INVALID_CATEGORIES.each do |work_category|
  #         post works_path, params: { work: { category: work_category,
  #           title: "foo" } }
  #         must_respond_with 400
  #       end
  #     }.wont_change 'Work.count'
  #   end
  #
  # end
  #
  # # show -----------------------------------------------------------------------
  # describe "show" do
  #
  #   it "succeeds for an extant work ID" do
  #     get work_path(works(:poodr).id)
  #     must_respond_with :success
  #   end
  #
  #   it "renders 404 not_found for a bogus work ID" do
  #     get work_path(42)
  #     must_respond_with 404
  #   end
  # end
  #
  # # edit -----------------------------------------------------------------------
  # describe "edit" do
  #   it "succeeds for an extant work ID" do
  #     get edit_work_path(works(:poodr).id)
  #     must_respond_with :success
  #   end
  #
  #   it "renders 404 not_found for a bogus work ID" do
  #     get edit_work_path(42)
  #     must_respond_with 404
  #   end
  # end
  #
  # # update ---------------------------------------------------------------------
  # describe "update" do
  #   it "succeeds for valid data and an extant work ID" do
  #     put work_path(works(:poodr).id), params: { work:
  #       { category: "movie", title: "foo" }
  #     }
  #
  #     updated_work = Work.find(works(:poodr).id)
  #     updated_work.title.must_equal "foo"
  #     updated_work.category.must_equal "movie"
  #
  #     must_respond_with :redirect
  #     must_redirect_to work_path(works(:poodr))
  #   end
  #
  #   it "renders bad_request for bogus data" do
  #     put work_path(works(:poodr).id), params: { work:
  #       { category: "bar", title: "foo" }
  #     }
  #     must_respond_with 404
  #   end
  #
  #   it "renders 404 not_found for a bogus work ID" do
  #     put work_path(42), params: { work: { category: "movie", title: "foo" } }
  #     must_respond_with 404
  #   end
  # end
  #
  # # destroy --------------------------------------------------------------------
  # describe "destroy" do
  #   it "succeeds for an extant work ID" do
  #
  #     delete work_path(works(:poodr).id)
  #     must_redirect_to root_path
  #   end
  #
  #   it "renders 404 not_found and does not update the DB for a bogus work ID" do
  #     delete work_path(42)
  #     must_respond_with 404
  #   end
  # end
  #
  # # upvote ---------------------------------------------------------------------
  # describe "upvote" do
  #
  #   # Is this right??
  #   it "redirects to the work page if no user is logged in" do
  #     post logout_path, params: { username: users(:kari).username }
  #     post upvote_path(works(:movie).id), params: {
  #       vote: { user: users(:kari), work: works(:movie).id }
  #     }
  #
  #     must_redirect_to work_path(works(:movie))
  #     must_respond_with :redirect
  #   end
  #
  #   it "redirects to the work page after the user has logged out" do
  #     user = users(:kari)
  #     OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
  #     post logout_path, params: { username: users(:kari).username }
  #     post upvote_path(works(:movie).id), params: {
  #       vote: { user: users(:kari), work: works(:movie).id }
  #     }
  #
  #     must_redirect_to work_path(works(:movie))
  #     must_respond_with :redirect
  #
  #   end
  #
  #   it "succeeds for a logged-in user and a fresh user-vote pair" do
  #     user = users(:kari)
  #     OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
  #     # post login_path, params: { username: users(:kari).username }
  #     post upvote_path(works(:movie).id), params: {
  #       vote: { user: user, work: works(:movie) }
  #     }
  #
  #     must_redirect_to work_path(works(:movie))
  #     must_respond_with :redirect
  #   end
  #
  #   it "redirects to the work page if the user has already voted for that work" do
  #     user = users(:kari)
  #     OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
  #     2.times do
  #       post upvote_path(works(:movie).id), params: {
  #         vote: { user: users(:kari), work: works(:movie) }
  #       }
  #     end
  #
  #     must_redirect_to work_path(works(:movie))
  #     must_respond_with :redirect
  #   end
  # end
end
