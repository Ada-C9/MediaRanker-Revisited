require 'test_helper'

describe WorksController do
  before do
    @poodr = works(:poodr)
    end
  describe 'Guest User-tests' do
    describe "Root" do
        it "succeeds with all media types" do
          # Precondition: there is at least one media of each category

            a_movie = Work.find_by(category: "movie")
            a_book = Work.find_by(category: "book")
            an_album = Work.find_by(category: "album")

            assert_not_nil(a_movie)
            assert_not_nil(a_book)
            assert_not_nil(an_album)

            get root_path
            must_respond_with :success
        end

        it "succeeds with one media type absent" do
          # Precondition: there is at least one media in two of the categories
          total_works = Work.all.count
          total_works.must_equal 4

          albums = Work.where(category: 'album')
          expected_size = total_works - albums.size
          albums.each do |album|
            album.destroy
          end

          Work.find_by(category: "album").must_be_nil

          updated_total = Work.all.count
          updated_total.must_equal expected_size

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
  describe 'Logged-in User' do
    before do
      @rihanna = users(:rihanna)
      @ada = users(:ada)
    end
    describe "Index" do
      it "succeeds when there are all works" do
        login(@rihanna)
        session[:user_id].must_equal @rihanna.id
        Work.all.count.must_equal 4
        get works_path
        must_respond_with :success
      end

      it "succeeds when there are no works" do
        login(@rihanna)
        session[:user_id].must_equal @rihanna.id
        Work.destroy_all
        Work.all.count.must_equal 0

        get works_path
        must_respond_with :success
      end
    end

    describe "New" do
      it "succeeds" do
        login(@rihanna)
        session[:user_id].must_equal @rihanna.id
        get new_work_path
        must_respond_with :success
      end
    end

    describe "Create" do
      it "creates a work with valid data for a real category" do
        login(@rihanna)
        session[:user_id].must_equal @rihanna.id
        proc{
          post works_path,
          params:
                {work:
                  {title: "a title", creator: "a creator", description: "This is a description", publication_year: 2008, category: "album"}}
        }.must_change 'Work.count', 1

        Work.last.title.must_equal "a title"
        Work.last.creator.must_equal "a creator"
        Work.last.description.must_equal "This is a description"
        Work.last.publication_year.must_equal 2008
        Work.last.category.must_equal "album"

        flash[:status].must_equal :success
        flash[:result_text].must_equal "Successfully created album #{Work.last.id}"

        must_respond_with :redirect
        must_redirect_to work_path(Work.find_by(title: "a title"))
      end


      it "renders bad_request and does not update the DB for bogus data" do
        login(@rihanna)
        session[:user_id].must_equal @rihanna.id
        proc{
            post works_path,
            params:
                  {work:
                    {title: " ", creator: "Tim Snyder", description: "A terrific read", publication_year: 2017, category: "book"}}
            }.wont_change 'Work.count'

        flash[:status].must_equal :failure
        flash[:result_text].must_equal "Could not create book"
        flash[:messages][:title].size.must_equal 1
        flash[:messages][:title][0].must_equal "can't be blank"

        must_respond_with :bad_request
      end

      it "renders 400 bad_request for bogus categories" do
        login(@rihanna)
        session[:user_id].must_equal @rihanna.id
        proc{
          post works_path,
          params:
                  {work:
                    {rating: "5", creator: "world", description: "foo", publication_year: 2008, category: "album"}}
          }.wont_change 'Work.count'

          flash[:status].must_equal :failure
          flash[:result_text].must_equal "Could not create album"
          assert_operator flash[:messages][:title].size,:>, 0

          must_respond_with :bad_request
      end
    end

    describe "Show" do
      it "succeeds for an extant work ID" do
        login(@rihanna)
        session[:user_id].must_equal @rihanna.id
        get work_path(works(:album).id)
        must_respond_with :success
      end

      it "renders 404 not_found for a bogus work ID" do
        login(@rihanna)
        session[:user_id].must_equal @rihanna.id
        not_included_ID = -1

        get work_path(not_included_ID)
        must_respond_with :missing
      end
    end

    describe "Edit" do
      it "succeeds for an extant work ID" do
        login(@rihanna)
        session[:user_id].must_equal @rihanna.id
        get edit_work_path(works(:another_album).id)
        must_respond_with :success
      end

      it "renders 404 not_found for a bogus work ID" do
        login(@rihanna)
        session[:user_id].must_equal @rihanna.id
        not_included_ID = -1
        get edit_work_path(not_included_ID)
        must_respond_with :missing
      end
    end

    describe "Update" do
      it "succeeds for valid data and an extant work ID" do
        login(@rihanna)
        session[:user_id].must_equal @rihanna.id
        new_title = "Updated title"

        proc{
          put work_path(works(:movie).id),
          params:
            {work:
              {title: new_title, creator:"Sandi Metz", description: "new description", publication_year: 2003, category:"movie"}}
            }.wont_change 'Work.count'

        updated_work = Work.find_by(title: new_title)
        updated_work.title.must_equal new_title
        updated_work.creator.must_equal "Sandi Metz"
        updated_work.description.must_equal "new description"
        updated_work.publication_year.must_equal 2003
        updated_work.category.must_equal "movie"

        flash[:status].must_equal :success
        flash[:result_text].must_equal "Successfully updated movie #{updated_work.id}"

        must_respond_with :redirect
        must_redirect_to work_path(updated_work.id)
      end

      it "renders bad_request for bogus data" do
        login(@rihanna)
        session[:user_id].must_equal @rihanna.id
        put work_path(@poodr.id),
         params:
                {work:
                  {title:" ", creator:"Sandi Metz", description: "new description", publication_year: 2003, category:"movie"}}

        flash[:status].must_equal :failure
        flash[:result_text].must_equal "Could not update book"
        assert_operator flash[:messages][:title].size,:>, 0

        must_respond_with :bad_request
      end

      it "renders 404 not_found for a bogus work ID" do
        login(@rihanna)
        session[:user_id].must_equal @rihanna.id
        non_existant_id = -1
        put work_path(non_existant_id)
        must_respond_with :missing
      end
    end

    describe "Destroy" do
      it "succeeds for an extant work ID" do
        login(@rihanna)
        session[:user_id].must_equal @rihanna.id
        proc{
              delete work_path(@poodr.id)

            }.must_change 'Work.count', -1

        Work.find_by(title: "Practical Object Oriented Design in Ruby").must_be_nil
        flash[:status].must_equal :success
        flash[:result_text].must_equal "Successfully destroyed book #{@poodr.id}"

        must_respond_with :redirect
        must_redirect_to root_path
      end

      it "renders 404 not_found and does not update the DB for a bogus work ID" do
        login(@rihanna)
        session[:user_id].must_equal @rihanna.id
            not_included_ID = -1
            delete work_path(not_included_ID)
            must_respond_with :missing
      end
    end

    describe "Upvote" do

      it "redirects to the homepg (work pg before OAuth) page if no user is logged in" do
      # A user will be redirected to hompepg if they attempt to see a restricted pg or run in to a routing error if they attempt to paste in an upvote path.

      proc{
            post upvote_path(works(:album).id)
            }.wont_change 'Vote.count'

        must_respond_with :redirect
        must_redirect_to root_path
      end

      it "redirects to the work page after the user has logged out" do

        # Confirm the user has been logged in
        login(@rihanna)
        session[:user_id].must_equal @rihanna.id


        # Confirm the same user has logged out
        delete logout_path
        session[:user_id].must_be_nil
        flash[:status].must_equal :success
        flash[:result_text].must_equal "You've logged out"

        # The same user attempts to cast vote - will be redirected to the homepage until they re-sign in.
        proc{
              post upvote_path(works(:album).id)
             }.wont_change 'Vote.count'

        must_respond_with :redirect
        must_redirect_to root_path
      end

      it "succeeds for a logged-in user and a fresh user-vote pair" do
        # Confirm a user has logged in
        login(@rihanna)
        session[:user_id].must_equal @rihanna.id

        # Same user cast's vote
        proc{
              post upvote_path(works(:movie).id)
            }.must_change 'Vote.count', 1

        Vote.last.user_id.must_equal @rihanna.id
        Vote.last.work_id.must_equal works(:movie).id

        flash[:status].must_equal :success
        must_respond_with :redirect
        must_redirect_to work_path(works(:movie).id)
      end

      it "redirects to the work page if the user has already voted for that work" do
        #log in user
        login(@ada)
        session[:user_id].must_equal @ada.id

        #user cast a single vote on an album
        proc{
              post upvote_path(works(:another_album).id)
            }.must_change 'Vote.count', 1

        Vote.last.user_id.must_equal @ada.id
        Vote.last.work_id.must_equal (works :another_album).id

        # user attempts to cast a duplicate vote
        proc{
              post upvote_path(works(:another_album).id)
            }.wont_change 'Vote.count'

        flash[:result_text].must_equal "Could not upvote"
        assert_operator flash[:messages][:user].size,:>, 0
        must_respond_with :redirect
        must_redirect_to work_path(works(:another_album).id)
      end
    end
  end
end
