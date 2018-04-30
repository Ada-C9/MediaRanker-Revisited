require "test_helper"


describe SessionsController do

  describe "create" do

    it "logs in an existing user and redirects to the root route, without creating a new database entry" do

      #Arrange
      start_count = User.count
      user = users(:user_1)
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))

      #Act
      get auth_callback_path(:github)

      #Assert

      ### Logs in an existing user:
      flash[:result_text].must_equal "Logged in successfully"
      session[:user_id].must_equal user.id

      ### Does not add to the database
      User.count.must_equal start_count

      ### Redirects to the root path
      must_redirect_to root_path

    end

    it "creates an account for a new user, logs th new user in, provides appropriate success messages, and redirects to the root route" do

      # Arrange

      start_count = User.count
      user = User.new(provider: "github", uid: 40420, username: "drywall_bob", email: "bob@drywall.com")
      initial_user_id = user.id
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))

      ### Validating arrangement:
      initial_user_id.must_be_nil

      # Act
      get auth_callback_path(:github)
      new_user = User.find_by(username: "drywall_bob")
      session_id_accessible = session[:user_id]

      # Assert

      ### Creates an account
      User.count.must_equal start_count + 1
      User.last.must_equal new_user
      initial_user_id.wont_equal new_user.id

      ### Logs the new user in
      session[:user_id].must_equal new_user.id

      ### Provides appropriate success messages
      flash[:result_text].must_equal "Successful first login!"

      ### Redirects to the root path
      must_redirect_to root_path

    end

    it "does not log in, and provides appropriate failure messages, if given data that Github cannot use for a login" do

      #Arrange
      start_count = User.count
      user = User.new(provider: "github", uid: "", username: "Ratso", email: "")
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))

      #Act
      get auth_callback_path(:github)
      bogus_user = User.find_by(username: "Ratso")
      session_id_accessible = session[:user_id]

      #Assert

      ### Does not log in
      session[:user_id].must_be_nil

      ### Does not add to the database
      bogus_user.must_be_nil
      User.count.must_equal start_count

      ### Provides appropriate failure messages
      flash[:status].must_equal :failure

      ### Redirects to the root path
      must_redirect_to root_path

    end

    it "does not log in, and provides appropriate failure messages, if unable to get a response from the provider" do

      #Arrange
      start_count = User.count
      user = User.new(provider: "github", uid: nil, username: "drywall_bob", email: "bob@drywall.com")

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))

      #Act
      get auth_callback_path(:github)
      failing_user = User.find_by(username: "drywall_bob")
      session_id_accessible = session[:user_id]

      #Assert

      ### Does not log in
      session[:user_id].must_be_nil

      ### Does not add to the database
      User.count.must_equal start_count
      failing_user.must_be_nil


      ### Provides appropriate failure messages
      flash[:status].must_equal :failure
      flash[:result_text].must_equal "Logging in through Github not successful"

      ### Redirects to root path
      must_redirect_to root_path

    end

    it "if given data that Github can use, but that our database will reject:  does not log in, does not add to the database, provides appropriate failure messages, and redirects to root path" do

      #Arrange
      start_count = User.count
      user = User.new(provider: "github", uid: 33333334, username: "username_3", email: "goopface@goopersunited.com")
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))

      #Act
      get auth_callback_path(:github)
      duplicate_user = User.find_by(email: "goopface@goopersunited.com")
      session_id_accessible = session[:user_id]

      #Assert

      ### Does Not Log In:
      session[:user_id].must_be_nil

      ### Does Not Add to the Database:
      duplicate_user.must_be_nil
      User.count.must_equal start_count

      ### Provides appropriate failure messages:
      flash[:status].must_equal :failure
      flash[:result_text].must_equal "An error occurred during User creation."

      ### Redirects to root_path
      must_redirect_to root_path

    end
  end

  describe "destroy" do

    it "logs out a logged-in user" do

      # Arrange
      user_2 = users(:user_2)
      login(user_2)


      ###Validate arrangement
      user_2_id = User.find_by(username: "username_2").id
      session[:user_id].must_equal user_2_id

      #Act
      delete logout_path

      #Assert
      session[:user_id].must_be_nil
      flash[:status].must_equal :success
      flash[:result_text].must_equal "Successfully logged out"
      must_redirect_to root_path
    end

  end

end
