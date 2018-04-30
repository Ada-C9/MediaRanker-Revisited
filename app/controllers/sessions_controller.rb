
class SessionsController < ApplicationController

  def login
    auth_hash = request.env["omniauth.auth"]

    if auth_hash["uid"]
      @user = User.find_by(uid: auth_hash["uid"], provider: auth_hash["provider"])

      if @user.nil?
        @user = User.build_from_github(auth_hash)
        flash[:status] = :success
        flash[:result_text] = "#{@user.username} logged in successfully"
      else
        flash[:status] = :success
        flash[:result_text] = "Successfully logged in as existing user #{@user.username}"
      end
      session[:user_id] = @user.id

    else
      flash[:error] = "Could not log in"
    end

    redirect_to root_path
  end

  def destroy
    if session[:user_id]
      current_user
      if session[:user_id] == @current_user.id
        session[:user_id] = nil
        flash[:status] = :success
        flash[:result_text] = "Successfully logged out"
      end
      redirect_to root_path
    else
      require_login
      flash[:status] = :failure
    end
  end
end
