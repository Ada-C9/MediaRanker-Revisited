class SessionsController < ApplicationController
  def login_form
  end

  def create
    auth_hash = request.env["omniauth.auth"]

    user = User.login(auth_hash)

    if user.id
      session[:user_id] = user.id
      flash[:result_text] = "Logged in successfully"
      redirect_to root_path


    else
      #
      # username = params[:username]
      # if username and user = User.find_by(username: username)
      #   session[:user_id] = user.id
      #   flash[:status] = :success
      #   flash[:result_text] = "Successfully logged in as existing user #{user.username}"
      # else
      #   user = User.new(username: username)
      #   if user.save
      #     session[:user_id] = user.id
      #     flash[:status] = :success
      #     flash[:result_text] = "Successfully created new user #{user.username} with ID #{user.id}"
      #   else
      #     flash.now[:status] = :failure
      #     flash.now[:result_text] = "Could not log in"
      #     flash.now[:messages] = user.errors.messages
      #     render "login_form", status: :bad_request
      #     return
      #   end
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
