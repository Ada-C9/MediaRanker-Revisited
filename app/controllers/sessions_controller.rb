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
