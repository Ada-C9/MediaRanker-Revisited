class SessionsController < ApplicationController
  def login_form
  end

  def create
    # controller responsible for the errors & redirect
    auth_hash = request.env['omniauth.auth']
    if auth_hash['uid']
      @user = User.find_by(uid: auth_hash[:uid], provider: 'github')
      if @user.nil?
        puts "No user found! Creating new username"

        @user = User.get_user_info(auth_hash)

        if @user.save
          # saved successfully
          session[:user_id] = @user.id
          flash[:status] = :success
          flash[:result_text] = "Logged in successfully"
          redirect_to root_path
        else
          # not saved successfully
          flash[:status] = :failure
          flash[:result_text] = "Could not log in"
          redirect_to root_path
        end

      else
        session[:user_id] = @user.id
        flash[:status] = :success
        flash[:result_text] = "Logged in successfully"
        redirect_to root_path
      end
    else
      flash[:status] = :failure
      flash[:result_text] = "NOT WORKING"
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
