class SessionsController < ApplicationController
  def login_form
  end

  def login
    auth_hash = request.env['omniauth.auth']

    if auth_hash['uid']
      @user = User.find_by(uid: auth_hash[:uid], provider: 'github')

      if @user.nil?
        @user = User.build_from_github(auth_hash)
        successful_save = @user.save

        if successful_save
          session[:user_id] = @user.id
          flash[:status] = :success
          flash[:result_text] = "Successfully created new user #{@user.username} with ID #{@user.id}"
          redirect_to root_path
        else
          flash[:error] = "Something happened at user creation"
          redirect_to root_path
        end
      else
        session[:user_id] = @user.id
        flash[:status] = :success
        flash[:result_text] = "Successfully logged in as existing user #{@user.username}"
        redirect_to root_path
      end
    else
      flash.now[:status] = :failure
      flash.now[:result_text] = "Could not log in via Github"
      flash.now[:messages] = @user.errors.messages
      redirect_to root_path
      return

    end

  end

  def logout
    session[:user_id] = nil
    flash[:status] = :success
    flash[:result_text] = "Successfully logged out"
    redirect_to root_path
  end
end
