require 'test_helper'

describe WorksController do
  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category

    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories

    end

    it "succeeds with no media" do

    end
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do
    it "succeeds when there are works" do
      Work.count.must_be :>, 0

      # Act
      get works_path

      # Assert
      must_respond_with :success
    end

    it "succeeds when there are no works" do
      Work.destroy_all
      # Book.all.length.must_equal 0

      # Act
      get works_path

      # Assert
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

      work_data = {
        title: "controller test work",
        category: Work.first.category,
        id: Work.last.id + 1
      }
      old_work_count = Work.count

      # Assumptions
      work = Work.new(work_data)
      work.must_be :valid?


      # Act
      post works_path, params: { work: work_data }


      # Assert
      must_respond_with :redirect
      must_redirect_to work_path(work.id)

      # Work.count.must_equal old_work_count + 1
      # Work.last.title.must_equal book_data[:title]
    end

    it "renders bad_request and does not update the DB for bogus data" do

      work_data = {title: 4, category:"not-a-category"}
      old_work_count = Work.count

      # Assumptions
      Work.new(work_data).wont_be :valid?

      # Act
      post works_path, params: { work: work_data }

      # Assert
      must_respond_with :bad_request
      Work.count.must_equal old_work_count
    end

    it "renders 400 bad_request for bogus categories" do
      work_data = {title: "fake-title", category:"not-a-category"}
      old_work_count = Work.count

      # Assumptions
      Work.new(work_data).wont_be :valid?

      # Act- this need params to succeed here, but not in the larger path world
      post works_path, params: { work: work_data }

      # Assert
      must_respond_with :bad_request
      Work.count.must_equal old_work_count

    end

  end


  describe "show" do
    it "succeeds for an extant work ID" do
      get work_path(Work.first)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      work_id = Work.last.id + 1
      get work_path(work_id )

      must_respond_with :not_found
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do
      get edit_work_path(Work.first)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      work_id = Work.last.id + 1
      get edit_work_path(work_id)

      must_respond_with :not_found

    end
  end

  describe "update" do
    it "succeeds for valid data and an extant work ID" do
      work = Work.first
      work_data = work.attributes
      work_data[:title] = "some updated title"

      # Assumptions
      work.assign_attributes(work_data)
      work.must_be :valid?

      # Act
      patch work_path(work), params: { work: work_data }

      # Assert
      must_redirect_to work_path(work)

      work.reload
      work.title.must_equal work_data[:title]
    end

      # it "renders bad_request for bogus data" do
      #   work = Work.first
      #   work_data = work.attributes
      #   work_data[:title] = ""
      #
      #   # Assumptions
      #   work.assign_attributes(work_data)
      #   work.wont_be :valid?
      #
      #   # Act
      #   patch work_path(work), params: { work: work_data }
      #
      # end

      it "renders 404 not_found for a bogus work ID" do
        work = Work.last
        id = Work.last.id + 10
        work_data = work.attributes
        work_data[:id] = id
        binding.pry

        # Assumptions
        work.assign_attributes(work_data)
        work.wont_be :valid?

        # Act
        patch work_path(work), params: { work: work_data }

        # Assert
        must_respond_with :not_found
      end
  end
end

#
# describe "destroy" do
#   it "succeeds for an extant work ID" do
#
#   end
#
#   it "renders 404 not_found and does not update the DB for a bogus work ID" do
#
#   end
# end
#
# describe "upvote" do
#
#   it "redirects to the work page if no user is logged in" do
#
#   end
#
#   it "redirects to the work page after the user has logged out" do
#
#   end
#
#   it "succeeds for a logged-in user and a fresh user-vote pair" do
#
#   end
#
#   it "redirects to the work page if the user has already voted for that work" do
#
#   end
# end
