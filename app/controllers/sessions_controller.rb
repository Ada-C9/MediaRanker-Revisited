class SessionsController < ApplicationController


  def create
    auth_hash = request.env['omniauth.auth']

    @user = User.login(auth_hash)
    if @user.save
      session[:user_id] = @user.id
      flash[:success] = "User #{@user.username} successfully logged in"
      redirect_to root_path
    else
      flash[:error] = "Could not log in"
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
