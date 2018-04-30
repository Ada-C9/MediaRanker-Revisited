class SessionsController < ApplicationController
  def login
    auth_hash = request.env['omniauth.auth']

    if auth_hash['uid']
      @user = User.find_by(uid: auth_hash[:uid], provider: 'github')
      if @user.nil?
        # User doesn't match anything in the DB
        # Attempt to create a new user
        @user = User.build_from_github(auth_hash)
          if @user.save
            login_success
          else
            login_failure
          end
        else
          login_success
        end
      else
        login_failure
      end
      redirect_to root_path
    end

    def logout
      if session[:user_id]
        session[:user_id] = nil
        flash[:status] = :success
        flash[:result_text] = "Successfully logged out"
      end
      redirect_to root_path
    end

    private
    def login_success
      session[:user_id] = @user.id
      flash[:status] = :success
      flash[:result_text] = "Successfully created new user #{@user.username} with ID #{@user.id}"
    end

    def login_failure
      flash[:status] = :failure
      flash[:result_text] = "Could not log in"
      flash[:messages] = @user.errors.messages
    end
end
