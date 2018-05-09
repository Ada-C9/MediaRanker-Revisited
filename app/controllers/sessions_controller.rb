require "pry"
class SessionsController < ApplicationController
  skip_before_action :authentication

  def login_form
  end

  def index
   @user = User.find(session[:user_id])
  end

  def login
    auth_hash = request.env['omniauth.auth']

    if auth_hash['uid']
      @user = User.find_by(uid: auth_hash[:uid], provider: 'github')
      if @user.nil?
        @user = User.build_from_github(auth_hash)
        successful_save = @user.save
        if successful_save
          flash[:success] = "Logged in successfully"
          redirect_to root_path
        else
          flash[:error] = "Some error happened in user creation"
          redirect_to root_path
        end
      else
       flash[:success] = "Logged in successfully"
       redirect_to root_path
      end

      session[:user_id] = @user.id
    else
     flash[:error] = "Could not log in"
     redirect_to root_path
    end
  end

  def logout
    session[:user_id] = nil
    flash[:success] = "Successfully logged out!"

    redirect_to root_path
  end
end
