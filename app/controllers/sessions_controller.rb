class SessionsController < ApplicationController
  def login
    auth_hash = request.env['omniauth.auth']

    if auth_hash['uid']
      @user = User.find_by(uid: auth_hash[:uid], provider: 'github')
      if @user.nil?
        @user = User.build_from_github(auth_hash)
        if @user.save
          session[:user_id] = @user.id
          flash[:status] = :success
          flash[:result_text] = "Successfully logged in as new user #{@user.username} with ID #{@user.id}"
        else
          flash[:status] = :failure
          flash[:result_text] = "Could not log in"
          flash[:messages] = @user.errors.messages
        end
      else
        session[:user_id] = @user.id
        flash[:status] = :success
        flash[:result_text] = "Successfully logged in as existing user #{@user.username} with ID #{@user.id}"
      end
    else
      flash[:status] = :failure
      flash[:result_text] = "Could not log in"
      flash[:messages] = @user.errors.messages
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
end
