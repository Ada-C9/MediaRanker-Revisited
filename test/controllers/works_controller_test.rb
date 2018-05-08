require 'test_helper'

# Test organization template:
# Arrange
# Assumptions
# Act
# Assert

describe WorksController do

  describe "root" do
    it "succeeds with all media types" do


      # Arrange
      # No need for arrange- data is inside works.yml
      category = %w(album movie book)

      # Assumptions

      # Act
      category.each do |cat|
        work = Work.find_by(category: cat)
        result =  work.valid?
        result.must_equal true
      end
      get root_path

      # Assert
      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      albums = Work.where(category: "album")
      albums.each do |album|
        album.destroy
      end

      get root_path

      # Assert
      must_respond_with :success

    end
    #
    it "succeeds with no media" do
      #Arrange
      Work.destroy_all

      Work.count.must_equal 0

      get root_path
      must_respond_with :success
    end
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", " ", "albumstraingtext"]

  describe 'logged in user' do
    before do
      @user = users(:kari)
    end

    describe "index" do
      it "succeeds when there are works" do
        login(@user)

        Work.any?.must_equal true
        get works_path
        must_respond_with :success
      end

      it 'succeeds when there are no works' do
        login(@user)
        works = Work.all

        works.each do |w|
          w.destroy
        end
        Work.count.must_equal 0
        get works_path
        must_respond_with :success
      end
    end

    describe 'new' do
      it 'succeeds with getting a new work view' do
        get new_work_path
        must_respond_with :success
      end
    end

    describe 'create' do
      it 'creates a work with valid data' do
        work_data = {
          title: "fake ass work",
          category: CATEGORIES.sample.singularize
        }
        Work.new(work_data).must_be :valid?
        old_work_count = Work.count
        post works_path, params: { work: work_data }

        must_respond_with :redirect
        must_redirect_to work_path(Work.last)

        Work.count.must_equal old_work_count + 1
        Work.last.title.must_equal work_data[:title]
      end

      it 'does with bad data' do
        work_data = {
          title: "",
          category: CATEGORIES.sample.singularize
        }
        Work.new(work_data).wont_be :valid?
        old_work_count = Work.count
        post works_path, params: { work: work_data }

        must_respond_with :bad_request

        Work.count.must_equal old_work_count
      end

      it 'does with bogus categories' do
        work_data = {
          title: "fake ass work",
          category: INVALID_CATEGORIES.sample.singularize
        }
        Work.new(work_data).wont_be :valid?
        old_work_count = Work.count
        post works_path, params: { work: work_data }

        must_respond_with :bad_request

        Work.count.must_equal old_work_count
      end


    end
  end
end

# describe "new" do
#   it "succeeds" do
#     # TODO: do we not test with any Works because this test doesn't touch the database?
#
#     get new_book_path
#
#     must_respond_with :success
#   end
# end

#   describe "create" do
#     it "creates a work with valid data for a real category" do
#       # go to create work page and fill out details of form and click submit button
#       # look at create action and see what the controller action/verb is and prefix
#       # Nicoleta used a proc here with params and a nested hash with work and title and category
#       # then after the proc must change the work count by one
#
#       #then must_respond_with (look at the create method- and see if it redirects -- surprise-- it does!)
#       # then must redirect to work path Work last
#
#     end
#
#     it "renders bad_request and does not update the DB for bogus data" do
#
#     end
#
#     it "renders 400 bad_request for bogus categories" do
#       # make each loop thru all the INVALID_CATEGORIES to loop over each category - put all below inside loop
#       # use a proc
#       # won't change work count
#       # must_respond_with bad request
#
#
#     end
#
#   end
#
#   describe "show" do
#     it "succeeds for an extant work ID" do
#
#     end
#
#     it "renders 404 not_found for a bogus work ID" do
#
#     end
#   end
#
#   describe "edit" do
#     it "succeeds for an extant work ID" do
#       # Assumptions
#
#       # Arrange
#       work = Work.first
#
#       # Act
#       edit_work_path(work)
#
#       # Assert
#       must_respond_with :success
#     end
#
#     it "renders 404 not_found for a bogus work ID" do
#
#     end
#   end
#
#   describe "update" do
#     it "succeeds for valid data and an extant work ID" do
#
#     end
#
#     it "renders bad_request for bogus data" do
#
#     end
#
#     it "renders 404 not_found for a bogus work ID" do
#
#     end
#   end
#
#   describe "destroy" do
#     it "succeeds for an extant work ID" do
#
#     end
#
#     it "renders 404 not_found and does not update the DB for a bogus work ID" do
#
#     end
#   end
#
#   describe "upvote" do
#
#     it "redirects to the work page if no user is logged in" do
#
#     end
#
#     it "redirects to the work page after the user has logged out" do
#
#     end
#
#     it "succeeds for a logged-in user and a fresh user-vote pair" do
#
#     end
#
#     it "redirects to the work page if the user has already voted for that work" do
#
#     end
#   end
#
#
#
#   # TODO look at the books_controller_test.rb tests that Dan did today April 18th
#   describe 'guest user' do
#     it 'rejects requests for new work form' do
#       get new_work_path
#       must_respond_with :unauthorized
#     end
#
#
#
#     it 'rejects requests to create a work' do
#
#
#     end
#
#     it 'rejects requests for the edit form' do
#     end
#
#     it 'rejects requests to update a work' do
#     end
#
#     it 'rejects requests to destroy a work' do
#     end
#   end
#

#  end
# end
