class SessionsController < ApplicationController
  def login_form
  end


  def create
    auth_hash = request.env['omniauth.auth']
    # TODO: dry up controller code and verify application view wrt flash messages
    if auth_hash['uid']
      @user = User.find_by(uid: auth_hash[:uid], provider: 'github')
      if @user.nil?
        # User doesn't match anything in the DB
        # Attempt to create a new user
        @user = User.build_from_github(auth_hash)
        if @user.save
          # saved successfully
          session[:user_id] = @user.id
          flash[:status] = :success
          flash[:result_text] = "Successfully created new user #{@user.username} with ID #{@user.id}"
          redirect_to root_path
        else
          # not saved successfully
          flash[:status] = :failure
          flash[:result_text] = "Could not log in"
          flash[:messages] = @user.errors.messages
          redirect_to root_path
        end
      else
        session[:user_id] = @user.id
        flash[:status] = :success
        flash[:result_text] = "Successfully logged in as existing user #{@user.username}"
        redirect_to root_path
      end
    else
      flash[:status] = :failure
      flash[:result_text] = "Could not log in"
      flash[:messages] = user.errors.messages
      redirect_to root_path
    end

  end

  def logout
    session[:user_id] = nil
    flash[:status] = :success
    flash[:result_text] = "Successfully logged out"
    redirect_to root_path
  end
end
